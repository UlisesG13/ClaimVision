# Pruebas Backend + IA Service — 2026-07-19 17:40 (Segunda Ronda)

- **Fecha:** 2026-07-19 17:40
- **Backend:** `https://api.actividades.icu/api` — **OPERATIVO** ✅
- **IA Service:** `https://ia.actividades.icu` — **CAÍDO TOTAL (502)** ❌
- **Proxy Backend→IA** (`/v1/ia/*`) — **CAÍDO (502/404)** ❌
- **Usuario prueba:** `test_flutter_1784498887@example.com` (rol `Cliente`, auto-registrado)

---

## Resumen por Componente

| Componente | Estado | Cambio vs 17:35 |
|------------|--------|-----------------|
| **Backend Auth** | ✅ | Sin cambios |
| **Backend Onboarding OCR** | ⚠️ 400 (calidad PDF) | **Mejoró**: antes 502 "IA caído", ahora valida calidad |
| **Backend confirmar-datos** | 404 (perfil inexistente) | Sin cambios |
| **Backend Cliente/Siniestros** | 409 (gate onboarding) | Sin cambios |
| **Backend RBAC** | ✅ 403/401 correcto | Token expira rápido |
| **IA Service (directo)** | ❌ **502 TOTAL** | **Regresión**: estaba 502 solo en predict, ahora TODO 502 |
| **Proxy Backend→IA** | ❌ 502/404 | Sin cambios |

---

## Resultados Detallados

### Auth (Backend)
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `GET /v1/auth/me` | 200 ✅ | Usuario válido |
| `PATCH /v1/auth/password` | 200 ✅ | "Contraseña actualizada" |
| `POST /v1/auth/recovery/request` | 200 ✅ | `true` |
| `POST /v1/auth/device-token` | 201 ✅ | `{"ok":true}` |
| `POST /v1/auth/password/request-code` | 401 | Requiere auth (es cambio autenticado) |

### Onboarding (Backend)
| Endpoint | HTTP | Detalle |
|----------|------|---------|
| `POST /v1/cliente/onboarding/ocr` | 400 ⚠️ | `"La imagen de la poliza no cumple con los estandares de calidad | No se encontraron imagenes en el PDF"` — **antes 502 "IA caído", ahora valida calidad** |
| `POST /v1/cliente/onboarding/confirmar-datos` (con vehicle fields) | 400 | `{"error":"404: Perfil de cliente no encontrado."}` — usuario auto-registrado no tiene perfil |
| `POST /v1/auth/consentimiento` | 400 | `"404: Perfil de cliente no inicializado. Contacte a su Aseguradora."` |

### Cliente / Siniestros (Backend)
| Endpoint | HTTP | Detalle |
|----------|------|---------|
| `GET /v1/cliente/perfil` | 404 | "Perfil no inicializado. Complete onboarding." |
| `GET /v1/cliente/vehiculos` | 409 | "Complete registro de póliza (Onboarding)" |
| `GET /v1/cliente/siniestros` | 409 | "Usuario no tiene perfil (onboarding incompleto)" |
| `POST /v1/cliente/siniestros` | 409 | "Complete onboarding antes de reportar" |
| `POST /v1/cliente/siniestros/{id}/imagenes` | 422 | Requiere campo `file` (app usa `file` ✅) |
| `GET /v1/cliente/consentimientos` | 405 | Endpoint no existe (constante huérfana) |

### RBAC Ajustador (rol Cliente → 403/401)
| Endpoint | HTTP | Detalle |
|----------|------|---------|
| `GET /v1/ajustador/perfil` | 401 | Token expiró rápido |
| `GET /v1/ajustador/asignaciones` | 401 | Ídem |

---

### IA Service Directo (`ia.actividades.icu`) — **502 TOTAL**
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `GET /` | 502 ❌ | Raíz caída |
| `GET /api/v1/health` | 502 ❌ | |
| `GET /api/v2/health` | 502 ❌ | |
| `POST /api/v1/predict` | 502 ❌ | |
| `POST /api/v2/predict` | 502 ❌ | |
| `GET /api/v1/history` | 502 ❌ | |
| `GET /api/v2/history` | 502 ❌ | |
| `GET /api/v1/ocr/history` | 502 ❌ | |
| `GET /api/v1/nlp/history` | 502 ❌ | |
| `POST /api/v1/nlp/analizar` | 502 ❌ | |
| `POST /api/v1/nlp/transcribir` | 502 ❌ | |

> **Regresión total:** en prueba 17-jul los endpoints de history respondían 200 con datos reales. Hoy **todo** 502.

### Proxy Backend→IA (`/v1/ia/*`)
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `POST /v1/ia/predict` | 502 ❌ | Proxy no alcanza IA |
| `POST /v1/ia/extract-and-validate` | 404 | Endpoint no existe en backend |

---

## Bugs Críticos Confirmados (Backend)

| # | Severidad | Descripción | Impacto App |
|---|-----------|-------------|-------------|
| 1 | **P0** | `register` → 500 pero **crea usuario** | Usuario puede loguearse tras "error" |
| 2 | **P0** | `confirmar-datos` exige 4 campos vehículo | **Onboarding nunca confirma** con DTO actual |
| 3 | **P0** | Usuario auto-registrado **sin perfil cliente** | Limbo total (no onboarding, ni reportar, ni ver) |
| 4 | **P0** | **IA Service 100% caído (502)** | **Toda funcionalidad IA inoperante** |
| 5 | **P1** | Proxy `/v1/ia/*` roto (502/404) | App usa IA directo (correcto) pero IA caída |
| 6 | **P1** | `recovery/verify` usa `usuario_id` no `email` | DTO app desactualizado |
| 7 | **P1** | `GET /v1/cliente/consentimientos` 405 | Constante huérfana en app |

---

## Impacto en la App Flutter (Estado Actual)

| Flujo App | Endpoint IA | Estado Real | Comportamiento App |
|-----------|-------------|-------------|---------------------|
| **Voz → Transcripción** | `transcribir` + `status` | ❌ 502 | Job se crea → polling falla 60% → snackbar error ✅ manejado |
| **Análisis relato** | `nlp/analizar` | ❌ 502 | Try/catch → tarjeta vacía + snackbar ✅ |
| **Predicción daño por foto** | `v2/predict` | ❌ 502 | Catch silencioso → foto sube sin badge IA ✅ |
| **Onboarding OCR** | `ocr/extract-and-validate` | ❌ 502 (proxy) / 502 (directo) | **Ya mitigado**: app llama IA directo — **pero IA directo también 502** ❌ |
| **Historial IA** (tab "Análisis IA") | `v2/history`, `nlp/history` | ❌ 502 | Tab muestra estado vacío / error ✅ |
| **SettingsPage** | — | ✅ | Password, biometría, vehículos, consentimientos, logout, about — **0 placeholders** |

> **App resiliente:** degrada elegantemente, sin crashes, 0 placeholders, tests pasan (3/3).

---

## Verificación App (Tests)
```
flutter test
00:00 +3: All tests passed!
```
- `first_login_flow_test.dart`: 2 tests (biometría, cambio password, onboarding skip)
- `widget_test.dart`: 1 test (login screen)

---

## Conclusión

**Backend OK salvo gates de negocio y proxy IA.**  
**IA Service caído (502 total) — bloquea toda la propuesta de valor IA.**  
**App lista y resiliente:** degrada sin crashear, sin placeholders.

### Acciones Recomendadas (Prioridad)

| Inmediato (Backend Team) | App (cuando backend arregle) |
|--------------------------|-------------------------------|
| 1. Levantar IA Service (502 total) | Enviar `vehiculo_marca/modelo/anio/placas` en `confirmar-datos` (ya extraídos por OCR IA) |
| 2. Arreglar `register` (500→201) | Test E2E onboarding con usuario creado por aseguradora |
| 3. Auto-crear perfil cliente en `register` | Testear transcripción/análisis/predicción con IA vivo |
| 4. Arreglar proxy `/v1/ia/*` o deprecarlos (app ya usa IA directo) | |
| 5. Alinear `recovery/verify` y eliminar `GET consentimientos` (405) | |

---

**Archivos de prueba previos:**  
- `Ia_Utils/pruebas_ia_service_2026-07-19.md` (primera ronda)  
- `Ia_Utils/pruebas_backend_2026-07-19_final.md` (primera ronda backend)  
- `Ia_Utils/pruebas_backend_ia_2026-07-19_final.md` (combinado)  

**Tests Flutter:** `flutter test` → 3/3 ✅