# Análisis de Errores HTTP 401 en `/api/v1/events/stream`

Este reporte detalla por qué se producen las alertas `HTTP 401 | GET /api/v1/events/stream | Credenciales inválidas o expiradas` en los logs del backend y cómo resolver el problema.

---

## 1. Respuesta Rápida

Los errores 401 ocurren porque **el cliente (la aplicación Flutter) está intentando conectarse al flujo de eventos en tiempo real (SSE) utilizando un token JWT que ya ha expirado o no es válido**. 

Esto se divide en tres fases según la línea de tiempo de tus logs:
1. **Antes del Login (17:13:56 - 17:14:08)**: La aplicación se inicia y tiene un token antiguo (expirado) en almacenamiento local. Intenta conectarse al SSE repetidamente cada 4 segundos.
2. **Durante el Login (17:14:12)**: Justo después de iniciar sesión con éxito (200 OK en `/auth/login`), un intento de reconexión anterior que ya estaba programado se ejecuta con el token viejo y genera un último 401. Milisegundos después, se inicia la conexión SSE correcta con el nuevo token (200 OK).
3. **Bucle Infinito Posterior (17:14:16 en adelante)**: Aunque la sesión ya es válida y la aplicación funciona correctamente, el bucle de intentos fallidos con el token viejo **nunca se detiene y sigue corriendo en segundo plano**, provocando logs de error 401 cada 4 segundos.

---

## 2. Causas Raíz del Problema

### Causa 1: El flujo de SSE (`SseService`) evade el interceptor global de Dio
En la aplicación Flutter, las peticiones HTTP normales usan la librería `Dio` y pasan por un interceptor (`DioClient`). Si alguna petición HTTP recibe un `401 Unauthorized`, el interceptor automáticamente:
1. Borra la sesión local (`storage.clearSession()`).
2. Cierra la conexión SSE.
3. Redirige al usuario a la pantalla de login (`handleUnauthorized()`).

Sin embargo, el SSE se conecta usando `HttpClient` nativo de Dart directamente (no a través de `Dio`), por lo que **los errores 401 en el flujo de SSE no disparan la desconexión global**. La app sigue creyendo que está logueada, y la conexión fallida sigue reintentando en paralelo.

### Causa 2: Ausencia de cancelación/limpieza del servicio anterior
Al iniciar la aplicación o al desloguear implícitamente, la instancia anterior de `SseService` que estaba en bucle de reintento con el token expirado no se destruye correctamente o sigue activa en memoria, intentando reconectarse con el token antiguo de forma infinita.

### Causa 3: El Gateway Proxy no soporta Streaming / SSE
En la arquitectura del proyecto, el microservicio `ClaimVision_Proxy` (puerta de enlace) intercepta todas las peticiones al puerto `8000`.
En [router.py](file:///home/manu/Documentos/Clases/Proyecto%20Integrador/ClaimVision_Proxy/router.py#L47-L54), el proxy realiza la petición al backend de manera síncrona/bloqueante usando:
```python
async with httpx.AsyncClient(timeout=60.0) as client:
    response = await client.request(...)
```
Dado que el endpoint de SSE del backend (`/events/stream`) es un flujo infinito (`StreamingResponse`), el proxy se queda bloqueado esperando a que termine la respuesta hasta que alcanza el timeout de 60 segundos y devuelve un error **`504 Gateway Timeout`**. 
Esto obliga al cliente a desconectarse y reintentar constantemente la conexión, lo cual agrava el problema y sobrecarga el backend.

---

## 3. Soluciones Propuestas

### Solución A: Detener el reintento inmediatamente si es un 401 (En Flutter)
En la aplicación móvil, debemos modificar el método `_connect` en `lib/shared/services/sse_service.dart` para asegurar que un error `401` cancele de manera definitiva cualquier reconexión y alerte al sistema de autenticación.

```diff
// lib/shared/services/sse_service.dart
      final response = await request.close();

      if (response.statusCode == 401) {
        _controller?.addError(Exception('Sesión expirada'));
+       disconnect(); // Detiene por completo la instancia y cierra recursos
        return;
      }
```

### Solución B: Limpieza de SSE al restaurar sesión inválida (En Flutter)
En `lib/features/auth/presentation/state/auth_controller.dart`, si al arrancar el token guardado resulta ser inválido, debemos asegurar que se limpie cualquier servicio de eventos activo:

```diff
// lib/features/auth/presentation/state/auth_controller.dart
  @override
  Future<AuthSession?> build() async {
    final session = await ref.read(getStoredSessionProvider)();
    _bootstrapped = true;
    if (session == null) return null;

    final valido = await ref.read(verifySessionProvider)();
    if (!valido) {
+     _disposeSse(); // Asegura detener cualquier conexión SSE previa
      await ref.read(logoutUserProvider)();
      return null;
    }
    return session;
  }
```

### Solución C: Habilitar el Soporte de Streaming en el Proxy (En Gateway)
Debemos actualizar [router.py](file:///home/manu/Documentos/Clases/Proyecto%20Integrador/ClaimVision_Proxy/router.py) para que detecte cuando se solicita un flujo de eventos (SSE) y transmita la respuesta de forma asíncrona en lugar de bloquearse esperando a que termine:

```python
# Importar en ClaimVision_Proxy/router.py
from fastapi.responses import StreamingResponse

# Modificar el endpoint del proxy para soportar streaming
@router.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def proxy_to_backend(request: Request, path: str):
    target_url = f"{BACKEND_URL}/{path}"
    # ... (lectura de cabeceras) ...

    # Si es el endpoint de eventos en tiempo real, usar streaming
    if "/events/stream" in path.lower() or "text/event-stream" in headers.get("accept", "").lower():
        async def stream_generator():
            async with httpx.AsyncClient(timeout=None) as client:
                async with client.stream(
                    method=request.method,
                    url=target_url,
                    headers=headers,
                    params=dict(request.query_params),
                ) as response:
                    async for chunk in response.aiter_bytes():
                        yield chunk

        return StreamingResponse(
            stream_generator(),
            status_code=200,
            media_type="text/event-stream",
        )

    # ... (comportamiento normal para el resto de peticiones HTTP) ...
```