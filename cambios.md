# Cambios realizados

## 1. Biometría — Clean Architecture

### Archivos nuevos
| Archivo | Propósito |
|---------|-----------|
| `lib/core/biometric/domain/entities/biometric_credentials.dart` | Entidad email + password cifrada |
| `lib/core/biometric/domain/services/biometric_auth_service.dart` | Abstract de `local_auth` |
| `lib/core/biometric/domain/repositories/biometric_repository.dart` | Interfaz del repositorio |
| `lib/core/biometric/data/datasources/biometric_local_datasource.dart` | AES-256-CBC + `SecureStorageService` |
| `lib/core/biometric/data/repositories/biometric_repository_impl.dart` | Implementación del repositorio |
| `lib/core/biometric/presentation/providers/biometric_providers.dart` | Providers Riverpod |

### Dependencia agregada
- `encrypt: ^5.0.3` (AES-256-CBC)

## 2. Primer inicio por usuario (no por dispositivo)

**`lib/core/constants/storage_keys.dart`**
- `primerInicio` → `primerInicioPara(String userId)` → `cv_primer_inicio_{userId}`
- Cada usuario tiene su propia marca de "primer inicio"

## 3. Logout ya no borra datos biométricos

**`lib/features/auth/presentation/state/auth_controller.dart`**
- Se eliminó `clearForUser(userId)` del `logout()`
- La huella persiste entre sesiones del mismo usuario

## 4. Login — botón biométrico

**`lib/features/auth/presentation/pages/login_page.dart`**
- El botón de huella se muestra **siempre** que el dispositivo tenga sensor (antes solo si había datos guardados)
- Auto‑login con huella solo si hay credenciales guardadas
- Manejo de errores: snackbar si falla autenticación, si no hay credenciales, o si hay excepción

## 5. Perfil — enrolamiento biométrico con diálogo

**`lib/features/auth/presentation/pages/profile_page.dart`**
- `_BiometricCard` visible para **Cliente y Ajustador** (antes solo Cliente)
- Switch ON → `AlertDialog` pide contraseña (evita el crash del inline `TextField`)
- Providers leídos **antes** del diálogo para evitar el error `_dependents.isEmpty`
- `setState` diferido con `Future.microtask` después del diálogo

## 6. Layout — cards con Material surface

**`_MenuCard`, `_BiometricCard`, `_ThemeCard`** en `profile_page.dart`
- Cambiadas de `Container` + `BoxDecoration` a `Material` con `shape` + `clipBehavior`
- Elimina el warning "ListTile background color or ink splashes may be invisible"
- Simplifica el árbol de widgets (sin `ClipRRect` anidado)

## 7. AndroidManifest

**`android/app/src/main/AndroidManifest.xml`**
- `android:enableOnBackInvokedCallback="true"` (elimina warning `WindowOnBackDispatcher`)

## Bugs corregidos

| Bug | Síntoma | Causa | Solución |
|-----|---------|-------|----------|
| PrimerInicio por dispositivo | Segundo usuario nunca ve modales | Clave fija `cv_primer_inicio` | Prefijo `{userId}` |
| Switch biométrico no responde | `Cannot hit test a render box with no size` | `setState` sincrónico dentro de `onChanged` del `SwitchListTile` + inline `TextField` | Diálogo + `Future.microtask` |
| `_dependents.isEmpty` | Pantalla roja al confirmar contraseña | Providers leídos después del `showDialog` | Leer providers antes del diálogo |
| Logout borra huella | Botón biométrico no aparece al reloguear | `clearForUser` en `logout()` | Eliminada la llamada |
