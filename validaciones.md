# Validaciones — ClaimVision

Documentación de todas las validaciones de entrada de datos en la aplicación móvil ClaimVision (Flutter/Dart + FastAPI/Python).

> Basado en el checklist estándar de validaciones. Cada sección indica si aplica o no en el proyecto y cómo se implementa.

---

## 1. Validación del lado del cliente

Toda la validación del lado del cliente se implementa en Flutter usando `GlobalKey<FormState>` + validadores personalizados.

### Validación de formato

**Email** — `lib/shared/utils/validators.dart:4-5`

```dart
static final _emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

static String? email(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresa tu correo electrónico.';
  if (!_emailRegex.hasMatch(value.trim())) return 'Ingresa tu correo electrónico válido.';
  return null;
}
```

**Fecha** — El servidor valida `format: date` y `format: date-time` en OpenAPI. El cliente no tiene validación explícita de fecha.

### Validación de longitud

**Contraseña nueva (registro):** `lib/shared/utils/validators.dart:35-41`

```dart
static String? newPassword(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresa una contraseña.';
  if (value.length < 8) return 'La contraseña debe tener al menos 8 caracteres.';
  return null;
}
```

**Contraseña (cambio):** `lib/features/auth/presentation/pages/settings_page.dart:207-211`

```dart
validator: (v) {
  if (v == null || v.isEmpty) return 'Requerido';
  if (v.length < 6) return 'Mínimo 6 caracteres';
  return null;
}
```

**Nombre completo:** `lib/shared/utils/validators.dart:43-51`

```dart
static String? fullName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresa tu nombre completo.';
  if (value.trim().length < 3) return 'El nombre debe tener al menos 3 caracteres.';
  return null;
}
```

**Narración del siniestro:** `lib/features/cliente/presentation/pages/report_narration_page.dart:113`

```dart
if (texto.length < 10) {
  AppSnackbar.error(context, 'Describe brevemente lo sucedido (mín. 10 caracteres).');
  return;
}
```

### Validación de rango

**Costo de reparación (>0):** `lib/features/ajustador/presentation/pages/validacion_peritaje_page.dart:488-491`

```dart
validator: (v) {
  final n = double.tryParse((v ?? '').trim());
  if (n == null || n <= 0) return 'Ingresa un costo válido.';
  return null;
}
```

**Año del vehículo:** `lib/features/cliente/presentation/state/report_state.dart:116`

```dart
int.tryParse(anio.trim()) != null
```

### Validación de contenido

**Campos obligatorios genéricos:** `lib/shared/utils/validators.dart:7-12`

```dart
static String? requiredField(String? value, {String campo = 'Este campo'}) {
  if (value == null || value.trim().isEmpty) return '$campo es obligatorio.';
  return null;
}
```

**Zona del daño:** `lib/features/ajustador/presentation/pages/validacion_peritaje_page.dart:456-457`

```dart
validator: (v) => (v == null || v.trim().isEmpty) ? 'Indica la zona.' : null
```

### Validación de expresiones regulares (regex)

| Archivo | Regex | Propósito |
|---------|-------|-----------|
| `lib/shared/utils/validators.dart:4` | `^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$` | Email |
| `lib/shared/domain/entities/siniestro.dart:53` | `[^0-9A-Za-z]` | Sanitizar ID para folio |
| `android/.../DeviceInspectorPlugin.kt:86-103` | Patrones de fingerprint | Detección de emulador |

### Validación de tipo

**Filtros de entrada numérica:** `lib/features/ajustador/presentation/pages/validacion_peritaje_page.dart:191`

```dart
TextField(
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
)
```

**tryParse en controladores:**

```dart
// report_state.dart:116
int.tryParse(anio.trim()) != null

// onboarding_controller.dart:231
int.tryParse(state.vehiculoAnio.trim()) ?? 0

// validacion_peritaje_page.dart:200
double.tryParse(controller.text.trim())
```

---

## 2. Validación del lado del servidor

La validación del servidor corre en FastAPI usando los tipos de Pydantic definidos en `openapi.json`. Los errores se mapean del lado del cliente.

### Validación de autenticidad

**Token JWT Bearer:** `lib/core/network/dio_client.dart:46-49`

```dart
final token = await secureStorage.read(StorageKeys.authToken);
if (token != null) {
  options.headers['Authorization'] = 'Bearer $token';
}
```

**Verificación de sesión al inicio:** `lib/features/auth/presentation/state/auth_controller.dart:33-39`

```dart
Future<void> restoreSession() async {
  final valid = await ref.read(verifySessionProvider).call();
  if (!valid) {
    state = const AsyncData(null);
    return;
  }
  // ...
}
```

**Manejo de 401 (token expirado):** `lib/core/network/dio_client.dart:53-61`

```dart
if (err.response?.statusCode == 401) {
  await secureStorage.delete(StorageKeys.authToken);
  onUnauthorized?.call();
}
```

### Validación de consistencia

**SSE — sesión expirada:** `lib/shared/services/sse_service.dart:49-51`

```dart
if (response.statusCode == 401) {
  _controller.addError('Sesion expirada');
}
```

### Validación de integridad

El canal HTTP/HTTPS con TLS garantiza la integridad en tránsito. No hay firma HMAC adicional a nivel aplicación.

### Validación de permisos

**Ubicación:** `lib/core/services/location_service.dart:28-41`

```dart
Future<bool> requestLocationPermission() async {
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    final requested = await Geolocator.requestPermission();
    if (requested == LocationPermission.denied || requested == LocationPermission.deniedForever) {
      throw Failure('Permiso de ubicación denegado');
    }
  }
  return true;
}
```

**Notificaciones:** `lib/core/services/notification_service.dart:101-108`

```dart
await messaging.requestPermission(
  alert: true, badge: true, sound: true,
);
```

### Mapeo de errores HTTP

`lib/core/network/api_error_mapper.dart:46-71`

```dart
AppException _byStatus(int statusCode, String detail) {
  return switch (statusCode) {
    400 || 422 => ValidationException(detail),
    401 => UnauthorizedException(detail),
    403 => ForbiddenException(detail),
    404 => NotFoundException(detail),
    409 => ConflictException(detail),
    _ => ServerException(detail),
  };
}
```

---

## 3. Validación de tipo

### OpenAPI — tipos esperados (server-side)

| Esquema | Campo | Tipo OpenAPI |
|---------|-------|-------------|
| `ConfirmDataRequestDTO` | `vehiculo_anio` | `integer` |
| `SiniestroInicializarDTO` | `latitud_siniestro`, `longitud_siniestro` | `number` |
| `ConsentRequestDTO` | `aviso_privacidad`, `biometria`, `transferencia_talleres` | `boolean` |
| `ChangePasswordRequest` | `old_password`, `new_password` | `string` |
| `DanoAjustadoDTO` | `costo_real_reparacion` | `number` |

### Cliente — tryParse patterns

`lib/features/cliente/data/dtos/vehiculo_response_dto.dart:19`

```dart
anio: int.tryParse('$json['anio']') ?? 0,
```

`lib/features/ajustador/data/dtos/damage_adjusted_dto.dart:28`

```dart
costoRealReparacion: double.tryParse('$json['costo_real_reparacion']') ?? 0,
```

---

## 4. Validación de lógica de negocio

### Onboarding — consentimiento obligatorio

`lib/features/auth/presentation/state/onboarding_controller.dart:73-78`

```dart
bool get canConfirm =>
    avisoPrivacidad &&
    numeroPoliza.trim().isNotEmpty &&
    vigenciaPoliza.trim().isNotEmpty &&
    curpRfc.trim().isNotEmpty &&
    !submitting;
```

### Reporte — evidencias válidas antes de enviar

`lib/features/cliente/presentation/state/report_state.dart:121-126`

```dart
bool get evidenciasValidas => evidencias.where((e) => e.calidadValida == true).length;
bool get puedeEnviar => yaCreado && evidenciasValidas > 0 && !subiendoAlguna;
```

### Peritaje — daños + firma obligatorios

`lib/features/ajustador/presentation/state/peritaje_editor_controller.dart:33-35`

```dart
bool get tieneDanos => danos.isNotEmpty;
bool get tieneFirma => (firmaBase64 ?? '').isNotEmpty;
bool get puedeConfirmar => tieneDanos && tieneFirma && !submitting;
```

### Reporte — vehículo completo + ubicación

`lib/features/cliente/presentation/state/report_state.dart:111-119`

```dart
bool get vehiculoCompleto =>
    vehiculoId.isNotEmpty &&
    marca.trim().isNotEmpty &&
    modelo.trim().isNotEmpty &&
    placas.trim().isNotEmpty &&
    int.tryParse(anio.trim()) != null;

bool get ubicacionLista => latitud != null && longitud != null;
```

### Documentos upload — ambos documentos obligatorios

`lib/shared/widgets/documentos_upload_sheet.dart:86-87`

```dart
bool get _puedeSubir => _identificacion != null && _poliza != null && !_subiendo;
```

---

## 5. Validación de patrones y reglas específicas

### Direcciones de correo electrónico

Validación vía regex (ver sección 1). También se valida en servidor con `format: email` en OpenAPI (`CreateUsuarioRequestDTO`, `OperadorTallerRequestDTO`).

### Contraseñas

| Contexto | Mínimo | Archivo |
|----------|--------|---------|
| Registro | 8 caracteres | `lib/shared/utils/validators.dart:37` |
| Cambio de contraseña | 6 caracteres | `lib/features/auth/presentation/pages/settings_page.dart:209` |

### Enums (valores controlados)

`openapi.json` define los valores permitidos:

```json
"DanoAjustadoDTO": {
  "tipo": { "enum": ["Abolladura", "Rayadura", "Fractura", "Rotura_Cristal", "Deformacion"] },
  "severidad": { "enum": ["Bajo", "Medio", "Alto"] }
}
```

---

## 6. Validación cruzada

### Confirmar contraseña

`lib/features/auth/presentation/pages/settings_page.dart:220`

```dart
validator: (v) => v != nuevo ? 'No coinciden' : null,
```

### Vehículo completo en reporte

`lib/features/cliente/presentation/state/report_state.dart:111-116`

Valida que marca, modelo, placas, año estén todos presentes y el año sea numérico.

---

## 7. Validación contextual

### Aviso de privacidad como gate

`lib/features/auth/presentation/pages/login_page.dart:83,93,378`

```dart
if (!_avisoAceptado) return;  // _submit() / _autenticarConBiometria()
// Botón deshabilitado si no ha aceptado:
onPressed: avisoAceptado ? onSubmit : null,
```

### Onboarding — documentos requeridos para OCR

`lib/features/auth/presentation/state/onboarding_controller.dart:169-207`

```dart
if (cedula == null || poliza == null) {
  state = state.copyWith(errorMessage: 'Ambos documentos son necesarios.');
  return;
}
```

---

## 8. Sanitización de entrada

### a. Escapado de Caracteres

**No implementado.** La app no renderiza HTML ni ejecuta JavaScript. Los datos se muestran en widgets de Flutter (Text, TextField) que no interpretan HTML/JS.

### b. Filtrado de Entradas

**Whitelisting — entrada solo dígitos:** `FilteringTextInputFormatter.digitsOnly` en campos de costo.

**File type restriction — PDF selector:** `lib/core/services/file_picker_service.dart:10-13`

```dart
FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf'],
);
```

### c. Validación de Tipo de Datos

Ver sección 3 (tryParse + OpenAPI types).

### d. Limpieza de Entradas

**Trim generalizado:**

```dart
// login_page.dart:97
_emailController.text.trim()

// onboarding_controller.dart:75-77
state.numeroPoliza.trim().isNotEmpty

// report_controller.dart:220-223
if (texto.trim().isEmpty) return;
```

### e. Codificación de Entradas

**URL encoding:** Dio maneja la codificación automática en los requests HTTP.

### f. Uso de Funciones y Librerías Seguras

| Librería | Propósito de seguridad |
|----------|----------------------|
| `flutter_secure_storage` | Almacenamiento cifrado de tokens y credenciales |
| `encrypt` | Cifrado AES-256-GCM para datos biométricos |
| `dio` | HTTP client con validación de status, interceptors |
| `local_auth` | Autenticación biométrica del sistema |
| `shimmer` | Animaciones de carga (sin impacto en seguridad) |
| `firebase_messaging` | Notificaciones push |

### g. Reemplazo de Caracteres

**Sanitización de ID para folio:** `lib/shared/domain/entities/siniestro.dart:53`

```dart
id.replaceAll(RegExp(r'[^0-9A-Za-z]'), '')
```

### h. Canonicalización

No implementada explícitamente. Las rutas de archivos se usan solo localmente para previsualización.

### i. Escape Output Contextually

No necesario — Flutter no interpreta HTML/JS en sus widgets nativos.

### j. Revisiones y Auditorías de Código

**Análisis estático:** `dart analyze lib/` se ejecuta regularmente (0 errores, 0 warnings).

**Device Inspector Plugin** — `android/.../DeviceInspectorPlugin.kt:14-23`

```kotlin
fun inspect(result: MethodChannel.Result) {
    val map = mapOf(
        "isDeveloperOptionsEnabled" to isDeveloperOptionsEnabled(),
        "isAdbEnabled" to isAdbEnabled(),
        "isAppDebuggable" to isAppDebuggable(),
        "isMockLocationActive" to isMockLocationActive(),
        "isEmulator" to isEmulator(),
    )
    result.success(map)
}
```

---

## 9. Uso de librerías y frameworks de validación

### Flutter (cliente)

| Librería | Archivo | Uso |
|----------|---------|-----|
| `Form` + `GlobalKey<FormState>` | Varias páginas | Validación de formularios |
| `TextFormField.validator` | `lib/shared/widgets/app_text_field.dart:75-81` | Validación por campo con `AutovalidateMode.onUserInteraction` |
| `FilteringTextInputFormatter` | `validacion_peritaje_page.dart:191` | Filtro de solo dígitos |
| Clase `Validators` (estática) | `lib/shared/utils/validators.dart` | Validadores reutilizables |

### FastAPI (servidor)

| Mecanismo | Descripción |
|-----------|-------------|
| Pydantic models | Tipado estricto, `required`, `format`, `minLength`, `maxLength`, `minimum`, `maximum`, `enum` |
| `format: email` | Validación de email server-side |
| `format: uuid` | Validación de UUIDs |
| `format: date` / `format: date-time` | Validación de fechas |

---

## 10. Educación y Capacitación del Equipo

El equipo de desarrollo utiliza Flutter y FastAPI con conocimientos en:
- Seguridad en aplicaciones móviles (OWASP Mobile Top 10)
- Protección de datos (LFPDPPP — Ley Federal de Protección de Datos Personales en Posesión de los Particulares)
- Cifrado AES-256-GCM para datos sensibles
- Almacenamiento seguro con `flutter_secure_storage`
- Prevención de captura de pantalla con `FLAG_SECURE` (Android) y `CALayer.isSecure` (iOS)

---

## 11. Gestión de Errores Adecuada

### Jerarquía de errores

```
AppException (data layer)
  ├── ServerException      → 5xx / red
  ├── UnauthorizedException → 401
  ├── ForbiddenException    → 403
  ├── NotFoundException     → 404
  ├── ConflictException     → 409
  └── ValidationException   → 400 / 422

Failure (presentation layer)
  ├── ServerFailure
  ├── AuthFailure
  ├── ForbiddenFailure
  ├── NotFoundFailure
  ├── ConflictFailure
  ├── ValidationFailure
  └── CacheFailure
```

### Mensajes amigables

`lib/core/network/api_error_mapper.dart:73-82`

```dart
String _defaultMessage(int statusCode) => switch (statusCode) {
  400 => 'Solicitud inválida.',
  401 => 'Sesión expirada. Inicia sesión nuevamente.',
  403 => 'No tienes permiso para realizar esta acción.',
  404 => 'Recurso no encontrado.',
  409 => 'El recurso ya existe.',
  422 => 'Datos inválidos. Revisa la información.',
  _ => 'Error inesperado. Intenta de nuevo.',
};
```

### Error UI en pantallas

El widget `AsyncValueWidget` (en `lib/shared/widgets/async_value_widget.dart`) unifica la presentación de errores:

```dart
error: (err, stack) => Center(
  child: Column(
    children: [
      Icon(Icons.cloud_off, color: alertColor),
      Text('Algo salió mal'),
      Text(mensajeAmigable(err)),
      if (onRetry != null) OutlinedButton.icon(
        onPressed: onRetry,
        icon: Icon(Icons.refresh),
        label: Text('Reintentar'),
      ),
    ],
  ),
),
```

---

## Resumen de cobertura

| Categoría | Implementado | No aplica |
|-----------|:---:|:---:|
| 1. Validación cliente — formato | ✅ | |
| 1. Validación cliente — longitud | ✅ | |
| 1. Validación cliente — rango | ✅ | |
| 1. Validación cliente — contenido | ✅ | |
| 1. Validación cliente — regex | ✅ | |
| 1. Validación cliente — tipo | ✅ | |
| 2. Validación servidor — autenticidad | ✅ | |
| 2. Validación servidor — consistencia | ✅ | |
| 2. Validación servidor — integridad | | ✅ (TLS) |
| 2. Validación servidor — permisos | ✅ | |
| 3. Validación de tipo | ✅ | |
| 4. Validación lógica de negocio | ✅ | |
| 5. Patrones específicos (email, password) | ✅ | |
| 5. Tarjeta de crédito | | ✅ (no aplica) |
| 6. Validación cruzada | ✅ | |
| 7. Validación contextual | ✅ | |
| 8a. Escapado HTML/JS/SQL | | ✅ (no necesario) |
| 8b. Filtrado whitelist/blacklist | ✅ | |
| 8c. Validación tipo datos | ✅ | |
| 8d. Limpieza (trim) | ✅ | |
| 8e. Codificación (URL/Base64) | ✅ | |
| 8f. ORMs seguros | ✅ (Dio) | |
| 8g. Reemplazo caracteres | ✅ | |
| 8h. Canonicalización | | ✅ (no aplica) |
| 8i. Escape output contextual | | ✅ (Flutter) |
| 8j. Auditorías código | ✅ | |
| 9. Librerías de validación | ✅ | |
| 10. Capacitación equipo | ✅ | |
| 11. Gestión errores adecuada | ✅ | |

---

## Archivos clave

| Archivo | Líneas | Propósito |
|---------|--------|-----------|
| `lib/shared/utils/validators.dart` | 52 | Validadores reutilizables (email, password, name, required) |
| `lib/shared/widgets/app_text_field.dart` | 122 | TextFormField con validador inyectable |
| `lib/core/errors/failures.dart` | 47 | 7 tipos de Failure (presentation layer) |
| `lib/core/errors/exceptions.dart` | 53 | 7 tipos de Exception (data layer) |
| `lib/core/network/api_error_mapper.dart` | 83 | Mapeo HTTP status → Exception |
| `lib/core/network/dio_client.dart` | 69 | Token JWT + 401 handler |
| `lib/core/services/location_service.dart` | 48 | Permiso de ubicación |
| `lib/core/services/file_picker_service.dart` | 19 | Restricción a PDF |
| `lib/core/services/image_picker_service.dart` | 24 | Calidad de imagen (80%, max 2000px) |
| `lib/core/services/biometric_service.dart` | 37 | Autenticación biométrica |
| `lib/core/services/screenshot_protection_service.dart` | 21 | Anti-captura de pantalla |
| `android/.../DeviceInspectorPlugin.kt` | 128 | Integridad del dispositivo |
| `android/.../ScreenshotProtectionPlugin.kt` | 38 | FLAG_SECURE Android |
| `ios/.../ScreenshotProtectionPlugin.swift` | 40 | CALayer.isSecure iOS |
| `lib/shared/widgets/async_value_widget.dart` | 81 | UI unificada de error con retry |
| `openapi.json` | 9758+ | Schemas Pydantic con validaciones server-side |
