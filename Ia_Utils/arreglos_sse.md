### 1. Detener el reintento de SSE ante un error 401 (App Flutter)

  • Archivo modificado: sse_service.dart
  • Cambio realizado: Al detectar un código de estado HTTP 401 en SseService._connect(), ahora se invoca de manera inmediata la función disconnect(). Esto fuerza la desconexión del
  cliente, vacía los recursos y evita que se vuelva a llamar de manera recursiva o programada en bucle infinito.
  ──────
  ### 2. Limpieza de SSE al restaurar sesión inválida (App Flutter)

  • Archivo modificado: auth_controller.dart
  • Cambio realizado: En el flujo de arranque de la aplicación (AuthController.build()), si existía una sesión guardada pero la verificación de sesión contra el backend devuelve
  valido == false (lo que indica un token expirado/borrado), ahora se llama a _disposeSse() explícitamente antes de cerrar la sesión. Esto previene que se queden conexiones SSE
  activas persistiendo en memoria con tokens antiguos tras el inicio de la app.
  ──────
  ### 3. Soporte de Streaming/SSE asíncrono real en el Proxy Gateway (Python)

  • Archivo modificado: router.py
  • Cambio realizado:
      • Se importó StreamingResponse de starlette.responses.
      • Se añadió una bifurcación en el middleware proxy_to_backend que detecta las peticiones de flujo en tiempo real (SSE) ya sea buscando el path /events/stream o leyendo el
      header accept: text/event-stream.
      • Manejo de estados no-200: Si el backend retorna algún error rápido como 401 Unauthorized (por token inválido/expirado) al intentar abrir el flujo, el gateway lo lee
      inmediatamente y lo devuelve como una respuesta convencional para que la app se entere del error exacto al instante.
      • Streaming: Si el backend responde con un HTTP 200 OK, el gateway abre un flujo asíncrono con client.stream(...) y utiliza StreamingResponse para transmitir los bytes en
      tiempo real. Al cerrarse la conexión, asegura la liberación y cierre de recursos asíncronos (response.aclose() y client.aclose()) mediante un bloque finally.

  ──────
  ### Resumen del resultado esperado

  Con estas modificaciones:

  1. Ya no se creará un bucle interminable de peticiones SSE reintentando conectarse con credenciales antiguas.
  2. Si el token expira, el backend responderá con 401, el cliente de SSE lo detectará, detendrá los reintentos inmediatamente y liberará la conexión.
  3. El proxy (puerto 8000) ahora transmitirá los eventos en tiempo real sin congelar la conexión ni arrojar molestos errores de 504 Gateway Timeout tras cada 60 segundos de
  inactividad.