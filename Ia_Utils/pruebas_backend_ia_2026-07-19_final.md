# Pruebas Backend + IA Service — Resumen Final 2026-07-19

- **Fecha:** 2026-07-19
- **Backend:** `https://api.actividades.icu/api` — **OPERATIVO** ✅
- **IA Service:** `https://ia.actividades.icu` — **CAÍDO TOTAL (502)** ❌
- **Herramientas:** curl + PowerShell
- **Usuario prueba:** `test_flutter_1784498887@example.com` (rol `Cliente`, auto-registrado)

---

## Estado General

| Componente | Estado | Detalle |
|------------|--------|---------|
| **Backend API** | ✅ Funcional | Todos los endpoints core responden correctamente |
| **IA Service (directo)** | ❌ Caído | 502 en **todos** los endpoints (health, predict, history, NLP, OCR) |
| **Backend → IA Proxy** | ❌ Caído | `/v1/ia/predict` → 502, `/v1/ia/extract-and-validate` → 404 |
| **RBAC Ajustador** | ✅ Funciona | 403 correcto con rol `Cliente` |

---

## Backend — Resultados Detallados

### Auth
| Endpoint | HTTP | Estado | Nota |
|----------|------|--------|------|
| `POST /v1/auth/register` | **500** ⚠️ | **BUG: crea usuario pero responde 500** | Login posterior funciona |
| `POST /v1/auth/login` | 200 ✅ | | Devuelve `primer_cambio_password` |
| `GET /v1/auth/me` | 200 ✅ | | |
| `PATCH /v1/auth/password` | 200 ✅ | | Limpia flag `primer_cambio_password` |
| `POST /v1/auth/password/request-code` | 401 | Requiere auth (es cambio autenticado) |
| `POST /v1/auth/recovery/request` | 200 ✅ | | Devuelve `true` |
| `POST /v1/auth/recovery/verify` | 422 ⚠️ | Requiere `usuario_id` (no `email`) |
| `POST /v1/auth/device-token` | 201 ✅ | | `{"ok":true}` |

### Onboarding
| Endpoint | HTTP | Estado | Nota |
|----------|------|--------|------|
| `POST /v1/cliente/onboarding/ocr` | **400** ❌ | **Proxy IA roto** → `"502: Servicio de IA: {'error': 'Not Found'}"` |
| `POST /v1/cliente/onboarding/confirmar-datos` | **422** ⚠️ | Requiere `vehiculo_marca/modelo/anio/placas` (la app no los manda) |
| `POST /v1/cliente/onboarding/confirmar-datos` (completo) | **400** 🔒 | Usuario auto-registrado **no tiene perfil cliente** (perfil lo crea aseguradora) |
| `POST /v1/auth/consentimiento` | **400** 🔒 | Mismo gate: "Perfil de cliente no inicializado" |

### Cliente v1
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `GET /v1/cliente/perfil` | 404 🔒 | "Perfil no inicializado. Complete onboarding" |
| `GET /v1/cliente/vehiculos` | 409 🔒 | "Complete registro de póliza" |
| `GET /v1/cliente/siniestros` | 409 🔒 | "Sin perfil cliente" |
| `GET /v1/cliente/siniestros/{id}` | 409 🔒 | Ídem |
| `POST /v1/cliente/siniestros` | 409 🔒 | "Complete onboarding antes de reportar" |
| `POST /v1/cliente/siniestros/{id}/imagenes` | 422 | Campo multipart **`file`** (la app usa `file` ✅ correcto) |
| `GET /v1/cliente/consentimientos` | 405 | Endpoint no existe (constante huérfana en app) |

### Ajustador (RBAC con rol Cliente)
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `GET /v1/ajustador/perfil` | 403 ✅ | "Rol requerido: Ajustador" |
| `GET /v1/ajustador/asignaciones` | 403 ✅ | Ídem |

### Proxy Backend → IA
| Endpoint | HTTP | Estado |
|----------|------|--------|
| `POST /v1/ia/predict` | **502** ❌ | Proxy no alcanza IA Service |
| `POST /v1/ia/extract-and-validate` | 404 | Endpoint no existe en backend |

---

## IA Service — Estado Actual (502 Total)

| Endpoint | HTTP | Estado |
|----------|------|--------|
| `GET /` | **502** ❌ | Raíz caída |
| `GET /docs` | **502** ❌ | Swagger caído |
| `GET /api/v1/health` | **502** ❌ | |
| `GET /api/v2/health` | **502** ❌ | |
| `POST /api/v1/predict` | **502** ❌ | |
| `POST /api/v2/predict` | **502** ❌ | |
| `GET /api/v1/history` | **502** ❌ | |
| `GET /api/v2/history` | **502** ❌ | |
| `GET /api/v1/ocr/history` | **502** ❌ | |
| `GET /api/v1/nlp/history` | **502** ❌ | |
| `POST /api/v1/nlp/analizar` | **502** ❌ | |
| `POST /api/v1/nlp/transcribir` | **502** ❌ | |
| `GET /api/v1/nlp/transcribir/status/{id}` | **502** ❌ | |

> **Regresión total:** en la prueba del 2026-07-17 los endpoints de *history* respondían 200 con datos reales. Hoy **todo** devuelve 502.

---

## Impacto en la App Flutter (lo ya implementado)

| Flujo App | Endpoint IA | Estado Real | Comportamiento App |
|-----------|-------------|-------------|---------------------|
| **Voz → Transcripción** (narración) | `transcribir` + `status` | ❌ 502 | Job se crea → polling falla 60% → snackbar error ✅ manejado |
| **Análisis relato** (página análisis) | `nlp/analizar` | ❌ 502 | Try/catch → tarjeta vacía + snackbar ✅ |
| **Predicción daño por foto** (badges) | `v2/predict` | ❌ 502 | Catch silencioso → foto sube sin badge IA ✅ |
| **Onboarding OCR** (cédula + póliza) | `ocr/extract-and-validate` | ❌ 502 (proxy backend) | **Ya mitigado**: app llama IA directo (`iaExtractAndValidateProvider`) — **pero IA directo también 502** ❌ |
| **Historial IA** (tab "Análisis IA") | `v2/history`, `nlp/history` | ❌ 502 | Tab muestra estado vacío / error ✅ |

> **Conclusión:** La app es **resiliente** (degrada sin crashear), pero **toda la funcionalidad IA está inoperante** hoy.

---

## Bugs y Breaking Changes Críticos (Backend)

| # | Severidad | Descripción | Impacto App |
|---|-----------|-------------|-------------|
| 1 | **P0** | `register` → 500 pero **crea usuario** | Usuario puede loguearse tras "error" |
| 2 | **P0** | `confirmar-datos` exige 4 campos de vehículo | **Onboarding nunca confirma** con DTO actual |
| 3 | **P0** | Usuario auto-registrado **no tiene perfil cliente** | Queda en limbo: no puede onboarding, ni reportar, ni ver siniestros |
| 4 | **P0** | IA Service **completamente caído** (502) | Toda funcionalidad IA inoperante |
| 5 | **P1** | Proxy backend `/v1/ia/*` roto (502/404) | App usa IA directo (correcto) pero IA caída |
| 6 | **P1** | `recovery/verify` usa `usuario_id` no `email` | DTO de app desactualizado |
| 7 | **P1** | `GET /v1/cliente/consentimientos` 405 | Constante huérfana en app |

---

## Acciones Recomendadas (Prioridad)

### Inmediato (Backend Team)
1. **Levantar IA Service** — investigar 502 (contenedor caído, salud, logs).
2. **Arreglar `register`** — debe devolver 201 tras crear usuario.
3. **Auto-crear perfil cliente** en `register` o habilitar endpoint de auto-inicialización.
4. **Alinear `confirmar-datos`** con DTO actual (añadir 4 campos vehículo) o documentar que frontend debe mandarlos (Fase 2 ya los extrae del OCR IA).
5. **Arreglar `recovery/verify`** para aceptar `email` + `code` o documentar `usuario_id`.
6. **Eliminar/renovar** `GET /v1/cliente/consentimientos` (405).

### App (ya mitigado / listo)
- ✅ Llamadas IA **directas** (sin proxy backend) — implementado en Fase 2.
- ✅ Manejo de errores 502/timeout en transcripción, análisis, predicción — try/catch + snackbar.
- ✅ Onboarding extrae campos de vehículo del OCR IA (`vehiculoMarca/Modelo/Anio/Placas`) — listos para enviar en `confirmar-datos` cuando backend lo acepte.
- ✅ SettingsPage funcional (password, biometría, vehículos, logout, about) — **eliminado "próximamente"**.

### Pendiente App (cuando backend arregle)
- Enviar `vehiculo_marca/modelo/anio/placas` en `ConfirmDataRequestDto` (ya están en estado).
- Testear onboarding E2E con usuario creado por aseguradora (tiene perfil).
- Testear transcripción/analisis/predicción con IA Service vivo.

---

## Verificación de la App (Tests)

```
flutter test
00:00 +3: All tests passed!
```

- `first_login_flow_test.dart`: 2 tests (biometría, cambio password, onboarding skip)
- `widget_test.dart`: 1 test (login screen)

**Sin placeholders:** único "próximamente" eliminado (`Configuración` → `SettingsPage` real con password, biometría, vehículos, consentimientos, logout, about).

---

## Conclusión

**Backend OK salvo gates de negocio y proxy IA.**  
**IA Service caído (502 total) — bloquea toda la propuesta de valor IA.**  
**App lista y resiliente:** degrada elegantemente, sin crashes, sin placeholders.