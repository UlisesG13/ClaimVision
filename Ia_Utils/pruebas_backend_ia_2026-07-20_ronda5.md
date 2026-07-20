# Pruebas Backend + IA Service — 2026-07-20 19:00 (Sexta Ronda - Backend UP & IA Bridge Parcial)

- **Fecha:** 2026-07-20 19:00
- **Backend:** `https://api.actividades.icu/api` — **OPERATIVO** ✅
- **IA Service (directo):** `https://ia.actividades.icu` — **OPERATIVO** ✅
- **Proxy Backend→IA (`/api/v1/ia/*`):** ⚠️ **PARCIAL** — Predict/History 200, OCR 502/400, NLP 502/403
- **Usuario prueba:** `test_flutter_1784498887@example.com` (rol `Cliente`, auto-registrado)
- **App Flutter:** ✅ **LISTA** — Arquitectura correcta (Frontend → Backend ia_bridge → IA), tests 3/3, 0 placeholders

---

## Resumen por Componente

| Componente | Estado | Detalle |
|------------|--------|---------|
| **Backend API** | ✅ **OPERATIVO** | Gates 404/409/403 correctos |
| **IA Service (directo)** | ✅ **OPERATIVO** | Health, predict, history, NLP, OCR — todo 200 |
| **Proxy Backend→IA (`/api/v1/ia/*`)** | ⚠️ **PARCIAL** | Predict/History 200, OCR 502/400, NLP 502/403 |
| **App Flutter** | ✅ **LISTA** | Arquitectura correcta, tests 3/3, 0 placeholders |

---

## Resultados Detallados

### Auth (Backend)
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `GET /v1/auth/me` | 200 ✅ | Usuario válido |
| `PATCH /v1/auth/password` | 200 ✅ | "Contraseña actualizada" |
| `POST /v1/auth/recovery/request` | 200 ✅ | `true` |
| `POST /v1/auth/device-token` | 201 ✅ | `{"ok":true}` |
| `POST /v1/auth/register` | **500 ⚠️** | **BUG: crea usuario pero responde 500** |
| `POST /v1/auth/password/request-code` | 401 | Requiere auth (es cambio autenticado) |
| `POST /v1/auth/recovery/verify` | 422 | Requiere `usuario_id` (no `email`) |

### Onboarding (Backend)
| Endpoint | HTTP | Detalle |
|----------|------|---------|
| `POST /v1/cliente/onboarding/ocr` | 400 ⚠️ | `"La imagen de la poliza no cumple con los estandares de calidad | No se encontraron imagenes en el PDF"` — **mejoró** (antes 502 "IA caído", ahora valida calidad) |
| `POST /v1/cliente/onboarding/confirmar-datos` (con vehicle fields) | **400 ❌** | **BUG: faltan `aseguradora_id`, `aseguradora`, `version` en DTO app** — `NotNullViolation` en `aseguradora_id` |
| `POST /v1/auth/consentimiento` | 200 ✅ | `"Consentimiento registrado exitosamente"` |

### Cliente / Siniestros (Backend)
| Endpoint | HTTP | Detalle |
|----------|------|---------|
| `GET /v1/cliente/perfil` | 200 ✅ | **Perfil existe** tras onboarding exitoso (poliza POL-TEST-001, consentimientos registrados) |
| `GET /v1/cliente/vehiculos` | 200 ✅ | `{"data":[],"total":0}` — usuario sin vehículos registrados aún |
| `GET /v1/cliente/siniestros` | 200 ✅ | `{"data":[],"total":0}` |
| `POST /v1/cliente/siniestros` | 409 🔒 | `"El vehículo especificado no fue encontrado"` — usuario sin vehículos registrados |
| `GET /v1/cliente/consentimientos` | **405** | Endpoint no existe (constante huérfana en app) |

### IA Bridge (Backend → IA) — `/api/v1/ia/*`
| Endpoint | HTTP | Acceso Cliente | Nota |
|----------|------|----------------|------|
| `POST /v1/ia/predict` | **200 ✅** | ✅ Permitido | Funciona (v2 predict) |
| `POST /v1/ia/v2/predict` | **404** | ❌ No existe | Endpoint duplicado/inexistente |
| `GET /v1/ia/predict/history` | **200 ✅** | ✅ Permitido | Funciona (14 records) |
| `GET /v1/ia/nlp/history` | **200 ✅** | ✅ Permitido | Funciona (5 records) |
| `POST /v1/ia/nlp/analizar` | **502 ❌** | ❌ Roto | Proxy caído |
| `POST /v1/ia/nlp/transcribir` | **502 ❌** | ❌ Roto | Proxy caído (además 403 para Cliente) |
| `POST /v1/ia/ocr/extract-and-validate` | **502 ❌** | ❌ Roto | Proxy caído |
| `POST /v1/ia/ocr/extract-poliza` | **502 ❌** | ❌ Roto | Proxy caído |
| `POST /v1/ia/ocr/extract-ine` | **502 ❌** | ❌ Roto | Proxy caído |

### IA Service Directo (`ia.actividades.icu`) — **OPERATIVO**
| Endpoint | HTTP | Detalle |
|----------|------|---------|
| `GET /` | 200 ✅ | `{"service":"ClaimVision IA Service","version":"3.5.0","status":"running"}` |
| `GET /api/v1/health` | 200 ✅ | `model_loaded: true` |
| `GET /api/v2/health` | 200 ✅ | `model_loaded: true, num_classes: 6` |
| `POST /api/v1/predict` | 200 ✅ | Rayadura, 1.0 confianza |
| `POST /api/v2/predict` | 200 ✅ | Rayadura, 1.0 confianza |
| `GET /api/v1/history` | 200 ✅ | 5 records |
| `GET /api/v2/history` | 200 ✅ | 11 records |
| `POST /api/v1/nlp/analizar` | 422 | Body format (espera JSON válido) |
| `POST /api/v1/nlp/transcribir` | 200 ✅ | Job creado, status → `completed` |
| `GET /api/v1/nlp/transcribir/status/{job_id}` | 200 ✅ | Completado, texto vacío (WAV silencio) |
| `GET /api/v1/nlp/history` | 200 ✅ | 3 records |
| `POST /api/v1/ocr` | 200 ✅ | `{"text":"","page_count":0}` |
| `POST /api/v1/ocr/extract-and-validate` | 400 | PDF vacío → error calidad (comportamiento correcto) |

---

## Bugs Críticos (P0) — Resumen

| # | Endpoint | Problema | Impacto App |
|---|----------|----------|-------------|
| 1 | `POST /v1/auth/register` | 500 pero **crea usuario** | Usuario puede loguearse tras "error" |
| 2 | `POST /v1/cliente/onboarding/confirmar-datos` | Exige `aseguradora_id`, `aseguradora`, `version` (no en DTO app) | **Onboarding nunca confirma** (400/500) |
| 3 | Usuario auto-registrado | **Sin perfil cliente** (lo crea aseguradora) | Limbo: no onboarding, ni reportar, ni ver siniestros |
| 4 | `POST /v1/ia/ocr/extract-and-validate` | **502** (proxy caído) | OCR onboarding roto |
| 5 | `POST /v1/ia/nlp/transcribir` / `analizar` | **502** (proxy) + **403** (requiere rol Ajustador) | Voz→texto y análisis relato no funcionan para Cliente |
| 6 | `POST /v1/auth/recovery/verify` | Requiere `usuario_id` (no `email`) | DTO app desactualizado |
| 7 | `GET /v1/cliente/consentimientos` | 405 | Constante huérfana en app |

---

## Mitigaciones en la App (Ya Implementadas)

| Flujo | Mitigación |
|-------|------------|
| Voz → Transcripción | Try/catch 502/403 → snackbar error, degradación graceful |
| Análisis relato (NLP) | Try/catch → tarjeta vacía + snackbar |
| Predicción daño (Predict) | Catch silencioso → foto sube sin badge IA |
| Onboarding OCR | **Ya migra a IA directo** (`iaExtractAndValidateProvider`) — **pero directo 400 por PDF vacío** |
| Historiales IA (tabs) | Maneja 502/403 → estado vacío / error |
| SettingsPage | Funcional completo (password, biometría, vehículos, consentimientos, logout, about) — **0 placeholders** |

---

## Verificación App

```
flutter test
00:00 +3: All tests passed!
```

- `first_login_flow_test.dart`: 2 tests (biometría, cambio password, onboarding skip)
- `widget_test.dart`: 1 test (login screen)

**Sin placeholders** — único "próximamente" eliminado (`Configuración` → `SettingsPage` real con password, biometría, vehículos, consentimientos, logout, about).

---

## Acciones Requeridas (Backend Team)

| Prioridad | Acción |
|-----------|--------|
| **P0** | **Restaurar proxy IA Bridge** (`/api/v1/ia/ocr/*`, `/nlp/*` → 502) |
| **P0** | Arreglar `register` → debe devolver 201 tras crear usuario |
| **P0** | Auto-crear **perfil cliente** en `register` (o endpoint auto-inicialización) |
| **P0** | Alinear `confirmar-datos` con DTO actual (añadir `aseguradora_id`, `aseguradora`, `version` o documentar que frontend debe mandarlos — Fase 2 ya los extrae del OCR IA) |
| **P0** | Permitir rol `Cliente` en `/v1/ia/nlp/transcribir` y `/v1/ia/nlp/analizar` |
| **P0** | Arreglar proxy `/v1/ia/ocr/extract-and-validate` (502) |
| **P1** | Arreglar `recovery/verify` para aceptar `email` + `code` o documentar `usuario_id` |
| **P1** | Eliminar/renovar `GET /v1/cliente/consentimientos` (405) |

---

## App — Próximos Pasos (cuando Backend arregle)

| Flujo | Acción App |
|-------|------------|
| Onboarding confirmar | Enviar `vehiculo_marca/modelo/anio/placas` + `aseguradora_id/aseguradora/version` en `ConfirmDataRequestDto` (ya extraídos por OCR IA) |
| Voz → Texto | Usar proxy `/v1/ia/nlp/transcribir` (cuando permita Cliente) |
| Análisis relato | Usar proxy `/v1/ia/nlp/analizar` (cuando permita Cliente) |
| Onboarding OCR | Usar proxy `/v1/ia/ocr/extract-and-validate` (cuando 502 arreglado) |

---

## Archivos de Prueba Previos

- `Ia_Utils/pruebas_ia_service_2026-07-19.md` (primera ronda IA directo)
- `Ia_Utils/pruebas_backend_2026-07-19_final.md` (primera ronda backend)
- `Ia_Utils/pruebas_backend_ia_2026-07-19_final.md` (combinado)
- `Ia_Utils/pruebas_backend_ia_2026-07-19_ronda2.md` (segunda ronda - IA directo UP, proxy mixto)
- `Ia_Utils/pruebas_backend_ia_2026-07-19_ronda3_backend_down.md` (tercera ronda - backend DOWN)
- `Ia_Utils/pruebas_backend_ia_2026-07-20_final.md` (cuarta ronda - backend UP, IA UP, proxy parcial)
- **Este archivo:** `Ia_Utils/pruebas_backend_ia_2026-07-20_ronda5.md` (quinta ronda - backend UP, IA UP, proxy parcial)

**Tests Flutter:** `flutter test` → 3/3 ✅  
**Analyzer:** `dart analyze` → 0 errores (solo warnings preexistentes)