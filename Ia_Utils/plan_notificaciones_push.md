# Plan de Implementación — Notificaciones Push Móvil

## Estado actual

- `NotificationService` inicializa Firebase, maneja FCM token, muestra notificaciones locales en foreground, y tiene handler en background.
- Token se registra en el backend al hacer login (`POST /api/v1/auth/device-token`).
- Backend aún no despliega el endpoint (existe en OpenAPI spec, devuelve 404).
- iOS: sin configuración de APNs ni `GoogleService-Info.plist`.
- Android: `google-services.json` placeholder (falta el real desde Firebase Console).

---

## 🔴 Fase 1 — Fundamental (imprescindible para producción)

### 1.1 Desplegar endpoint `POST /api/v1/auth/device-token` en backend   `[Backend]`
- El endpoint ya está definido en OpenAPI spec.
- Hay que redeployar la última versión del backend en `api.actividades.icu`.
- **Verificación**: `curl -X POST https://api.actividades.icu/api/v1/auth/device-token -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"token":"test"}'` debe devolver 201.

### 1.2 Configurar Firebase Console y archivos nativos   `[Flutter]`
- Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) desde Firebase Console → Configuración del proyecto → Cuentas de servicio.
- Reemplazar placeholders en `android/app/google-services.json` y crear `ios/Runner/GoogleService-Info.plist`.
- **iOS solo**: habilitar Push capability en Xcode (Signing & Capabilities → + → Push Notifications).

### 1.3 Configurar APNs en Firebase Console (iOS)   `[Firebase/iOS]`
- Generar APNs Authentication Key desde Apple Developer Console (Certificates → Keys → + → Apple Push Notifications service).
- Subir la key `.p8` a Firebase Console → Configuración del proyecto → Cloud Messaging → APNs Authentication Key.
- Alternativa: subir el certificate `.p12`.

### 1.4 Navegación al tocar notificación   `[Flutter]`
- Definir payload tipado:

```dart
class NotificationPayload {
  final String type; // 'siniestro', 'peritaje', 'sistema'
  final String? id;
  final String? url;
}
```

- En `main.dart` o un provider central, suscribirse a `onMessageOpenedApp` y `getInitialMessage` para navegar:
  - `type: siniestro` → `/siniestro/:id`
  - `type: peritaje` → `/ajustador/siniestro/:id`
  - `type: sistema` → `/perfil`
- Extraer el `payload` del `RemoteMessage.data`.

### 1.5 Borrar token en logout   `[Flutter]`
- Crear endpoint `DELETE /api/v1/auth/device-token` en OpenAPI + backend.
- En Flutter, cuando el usuario hace logout, llamar `DELETE` antes de limpiar sesión.
- Si el endpoint no responde, no bloquear el logout.

---

## 🟡 Fase 2 — Mejora de UX

### 2.1 Canales de notificación (Android)   `[Flutter]`
- Crear canales al inicializar el servicio:

| Canal ID              | Nombre                  | Descripción                       | Importancia |
|-----------------------|-------------------------|-----------------------------------|-------------|
| `siniestros`          | Siniestros              | Nuevos siniestros y actualizaciones | High        |
| `peritajes`           | Peritajes               | Asignaciones de ajuste             | High        |
| `sistema`             | Sistema                 | Cambios de cuenta, términos        | Default     |

- Elegir canal según `message.data['channel']` al mostrar la notificación.

### 2.2 In-App banner personalizado   `[Flutter]`
- Cuando la app está en foreground y llega una notificación:
  - En lugar de (o además de) mostrar notificación local del sistema, mostrar un banner overlay animado (OverlayEntry o Flushbar/Snackbar).
  - Al tocar el banner, navegar igual que al tocar la notificación del sistema.
  - Al deslizar arriba, descartar.
- Librerías útiles: `overlay_support`, `flutter_local_notifications` ya incluida.

### 2.3 Silent data messages   `[Flutter]`
- Si `message.data['silent'] == 'true'`, no mostrar UI.
- Usar para refrescar datos en background (ej: actualizar lista de siniestros).
- Integrar con Riverpod: al recibir silent message, invalidar el provider relevante.

### 2.4 Suscripción por topics según rol   `[Flutter + Backend]`
- Al registrarse/login, suscribir al usuario al topic correspondiente:
  - `role: cliente` → `/topics/clientes`
  - `role: ajustador` → `/topics/ajustadores`
- Permite al backend enviar notificaciones masivas sin conocer device tokens individuales.
- Implementar en `NotificationService.subscribeToRoleTopic(String role)`.

---

## 🟢 Fase 3 — Pulido

### 3.1 Botones de acción en notificación   `[Flutter]`
- Ej: notificación de peritaje asignado → botones "Aceptar" / "Rechazar".
- Configurar `AndroidNotificationDetails.actions` con `Icon` y `Title`.
- Manejar la acción en `onDidReceiveNotificationResponse`.

### 3.2 Grouping de notificaciones   `[Flutter]`
- Usar `setGroup('siniestros')` y `setGroupSummary(true)` en Android.
- Evita saturar al usuario cuando llegan múltiples notificaciones del mismo tipo.

### 3.3 Pantalla de preferencias   `[Flutter]`
- Agregar sección en Ajustes con toggles por canal.
- Guardar preferencias con `SharedPreferences` o `flutter_secure_storage`.
- Filtrar notificaciones antes de mostrarlas según preferencias.

### 3.4 Badge count   `[Flutter]`
- Actualizar badge con `flutter_app_badger` o `FlutterLocalNotificationsPlugin`.
- Al leer notificaciones, decrementar badge.

### 3.5 BigText / BigPicture styles   `[Flutter]`
- Si `message.data['image']` existe, mostrarla en la notificación expandida.
- Si el texto es largo (>50 chars), usar `BigTextStyle`.

---

## Dependencias externas (no código)

| Recurso                          | Quién lo genera               |
|----------------------------------|-------------------------------|
| `google-services.json`           | Firebase Console (Android)    |
| `GoogleService-Info.plist`       | Firebase Console (iOS)        |
| APNs Auth Key `.p8`              | Apple Developer Console       |
| Despliegue backend con endpoint  | DevOps / Backend team         |

---

## Resumen de entregas

| Fase | Entrega                             | Dependencias              |
|------|-------------------------------------|---------------------------|
| 1    | Notificaciones funcionales básicas  | Firebase Console, APNs    |
| 2    | UX pulida (canales, banner, silent) | Fase 1 completa           |
| 3    | Features extra (acciones, badge)    | Fase 2 completa           |
