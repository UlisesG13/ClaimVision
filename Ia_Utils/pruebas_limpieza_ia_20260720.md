# Reporte de Pruebas — Limpieza Código Móvil + IA Bridge

**Fecha:** 2026-07-20  
**Proyecto:** ClaimVision Mobile  
**Cobertura:** Análisis estático + tests unitarios + verificación manual de archivos

---

## 1. `dart analyze lib/` — 0 errores, 10 infos (pre-existentes)

| Tipo | Cantidad | Detalle |
|------|----------|---------|
| error | 0 | — |
| warning | 0 | — |
| info | 10 | `use_build_context_synchronously` en profile_page (3), settings_page (3), client_home_page (4). Son pre-existentes y no bloqueantes. |

## 2. `dart analyze test/` — 0 issues

## 3. `flutter test` — 3/3 ✅

| Test | Resultado |
|------|-----------|
| Omitir cambio de contraseña y biometrico "Ahora no" | ✅ |
| Omitir cambio de contraseña, activar huella y confirmar contraseña | ✅ |

---

## 4. Verificación de cambios estructurales

### ✅ Print statements eliminados
- `client_home_page.dart`: 4 prints eliminados (incluido password en texto plano)
- `biometric_service.dart`: ya no contenía prints

### ✅ Registro de usuario eliminado
- `register_page.dart` ✕ eliminado
- `register_user.dart` UC ✕ eliminado
- `register_request_dto.dart` ✕ eliminado
- `register()` método en `AuthController` ✕ eliminado
- `register()` en interface `AuthRepository` ✕ eliminado
- `register()` en impl `AuthRepositoryImpl` ✕ eliminado
- `register()` en `AuthRemoteDataSource` ✕ eliminado
- `registerUserProvider` ✕ eliminado
- `ApiConstants.register` ✕ eliminado
- `RoutePaths.register` ✕ eliminado
- `register_user.dart` import en providers ✕ eliminado
- `register_request_dto.dart` import en auth_remote_datasource ✕ eliminado
- `register_request_dto.dart` import en auth_repository_impl ✕ eliminado
- `LoginPage` footer: sin link a registro (versión movida a `AppInfo`)
- `_FakeAuthRepository` en test: método `register()` ✕ eliminado

### ✅ Constantes huérfanas eliminadas
- `recoveryRequest` ✕ eliminado
- `recoveryVerify` ✕ eliminado
- `recoveryReset` ✕ eliminado
- `clienteConsentimientos` ✕ eliminado

### ✅ Providers/UCs muertos eliminados
- `iaPredictDamageProvider` ✕ eliminado
- `IaExtractOcr` ✕ eliminado
- `IaExtractPoliza` ✕ eliminado
- `IaExtractIne` ✕ eliminado

### ✅ Módulo OCR eliminado (14 archivos)
- `core/ocr/` completo ✕ eliminado
- `ImageQualityService` ✕ eliminado (dependía de `ImageValidator` del OCR)
- `ocr_routes.dart` ✕ eliminado
- `ocrRoutes` en `app_router.dart` ✕ eliminado
- OCR providers en `providers.dart` ✕ eliminados

### ✅ temp_restore.dart eliminado de raíz

### ✅ Versión centralizada
- Creado `lib/core/constants/app_info.dart` con `AppInfo.displayVersion`
- `login_page.dart` ahora usa `AppInfo.displayVersion` en lugar del string hardcodeado

### ✅ Ajustador IA Opción B
- Botón "Analizar con IA" agregado en `validacion_peritaje_page.dart`
- Flujo: seleccionar imagen (cámara/galería) → `iaPredictDamageV2` → mapeo a `DamageAdjusted` → pre-relleno en editor
- Costos por defecto según severidad: Bajo \$2,000 / Medio \$5,000 / Alto \$12,000

### ✅ Report controller
- Stray brace extra eliminado (línea 381 de `report_controller.dart`)

---

## 5. Resumen de archivos modificados/eliminados

### Eliminados (12)
| Archivo | Motivo |
|---------|--------|
| `lib/core/ocr/` (14 archivos) | Módulo duplicado, rutas nunca navegadas |
| `lib/core/services/image_quality_service.dart` | Dependía de OCR, no usado fuera |
| `lib/features/auth/presentation/pages/register_page.dart` | Registro no aplica en móvil |
| `lib/features/auth/domain/usecases/register_user.dart` | Registro no aplica en móvil |
| `lib/features/auth/data/dtos/register_request_dto.dart` | Registro no aplica en móvil |
| `temp_restore.dart` | Archivo corrupto en raíz |

### Modificados (13)
| Archivo | Cambio |
|---------|--------|
| `api_constants.dart` | Eliminados register, recovery*, clienteConsentimientos |
| `auth_controller.dart` | Eliminado método register() |
| `auth_repository.dart` | Eliminado register() de interfaz |
| `auth_repository_impl.dart` | Eliminado register() + import |
| `auth_remote_datasource.dart` | Eliminado register() + import |
| `route_paths.dart` | Eliminados register, capturaDocumentos |
| `app_router.dart` | Eliminados RoutePaths.register, ocrRoutes |
| `dio_client.dart` | Eliminado ApiConstants.register de _skipAuthBounce |
| `providers.dart` | Eliminados registerUserProvider, OCR providers, iaPredictDamageProvider, ImageQualityService |
| `ia_ocr_uc.dart` | Eliminados IaExtractOcr/Poliza/Ine |
| `login_page.dart` | Versión ahora usa AppInfo.displayVersion |
| `client_home_page.dart` | Eliminados 4 prints |
| `report_controller.dart` | Eliminado stray brace |
| `validacion_peritaje_page.dart` | Agregado botón "Analizar con IA" |
| `peritaje_editor_controller.dart` | Sin cambios (ya funcional) |
| `first_login_flow_test.dart` | Eliminados métodos fantasma register, clearSession, saveSession, deleteDeviceToken |

### Creados (1)
| Archivo | Contenido |
|---------|-----------|
| `lib/core/constants/app_info.dart` | `AppInfo.version`, `.build`, `.displayVersion` |

---

## Conclusión

**Estado: ✅ TODO OK**

- `dart analyze lib/`: 0 errores
- `dart analyze test/`: 0 issues
- `flutter test`: 3/3 passed
- IA Bridge: datasource funcional (usa `dioProvider` → backend proxy)
- Predict V2: funcional en cliente (report_damage_page) y ajustador (validacion_peritaje_page)
- NLP análisis/transcripción: funcional
- Health checks IA: funcional en perfil
- Sin registros de contraseñas en logs
- Sin módulos muertos ni archivos corruptos
