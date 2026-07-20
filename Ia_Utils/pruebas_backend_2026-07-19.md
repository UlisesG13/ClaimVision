# Pruebas Backend Principal — ClaimVision

- **Fecha:** 2026-07-19
- **Base URL:** `https://api.actividades.icu`
- **Herramienta:** curl + PowerShell
- **Usuario de prueba:** `test_flutter_1784498887@example.com` (rol `Cliente`, auto-registrado)
- **Contexto:** verificación de los endpoints que consume la app Flutter tras la integración IA

## Resumen

| Estado | Cantidad | Detalle |
|--------|----------|---------|
| ✅ OK (2xx) | 8 | root, docs, login, me, password, recovery/request, device-token, rbac 403s |
| ⚠️ Con salvedad | 5 | register (500 pero crea), confirmar-datos (422 por campos faltantes), imagenes (422 campo `file`), consentimiento (400 sin perfil), recovery/verify (422 usuario_id) |
| ❌ Error | 3 | onboarding/ocr (proxy IA roto), `/v1/ia/*` (502), consentimientos GET (405) |
| 🔒 Gate de negocio | 5 | perfil/vehículos/siniestros → 404/409 hasta completar onboarding (esperado) |

## Resultados detallados

### General

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| GET | `/` | **200** ✅ | `{"Status":"OK"}` |
| GET | `/docs` | **200** ✅ | Swagger disponible |

### Auth

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/v1/auth/register` | **500** ⚠️ | `{"error":"Ocurrió un error interno..."}` — **BUG: el usuario SÍ se crea** (login posterior funciona). Falla algún paso post-creación (email de bienvenida o init de perfil) |
| POST | `/v1/auth/login` | **200** ✅ | Token JWT + `usuario_id`, `rol`, `primer_cambio_password: true` |
| GET | `/v1/auth/me` | **200** ✅ | Datos del usuario autenticado |
| PATCH | `/v1/auth/password` | **200** ✅ | `{"message":"Contraseña actualizada exitosamente"}` — limpia `primer_cambio_password` → `false` (verificado con re-login) |
| POST | `/v1/auth/password/request-code` | **401** | Requiere autenticación — es flujo de cambio autenticado, NO recovery |
| POST | `/v1/auth/recovery/request` | **200** ✅ | Devuelve `true` (código enviado) |
| POST | `/v1/auth/recovery/verify` | **422** ⚠️ | Requiere `usuario_id` (NO `email`). La app aún no consume este endpoint |
| POST | `/v1/auth/device-token` | **201** ✅ | `{"ok":true}` — registro FCM funciona |

### Onboarding

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/v1/cliente/onboarding/ocr` | **400** ❌ | `{"error":"502: Servicio de IA: {'error': 'Not Found'}"}` — **el proxy backend→IA está roto** |
| POST | `/v1/cliente/onboarding/confirmar-datos` | **422** ⚠️ | **Requiere campos que la app NO envía:** `vehiculo_marca`, `vehiculo_modelo`, `vehiculo_anio`, `vehiculo_placas`. La app solo manda `numero_poliza`, `vigencia_poliza`, `curp_rfc` |
| POST | `/v1/cliente/onboarding/confirmar-datos` (completo) | **400** | `{"error":"404: Perfil de cliente no encontrado."}` — usuarios auto-registrados **no tienen perfil de cliente**; el perfil lo crea la aseguradora |
| POST | `/v1/auth/consentimiento` | **400** | `{"error":"404: Perfil de cliente no inicializado. Contacte a su Aseguradora."}` — mismo gate de perfil |

### Cliente v1

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| GET | `/v1/cliente/perfil` | **404** 🔒 | `"Perfil de cliente no inicializado. Complete su onboarding."` |
| GET | `/v1/cliente/vehiculos` | **409** 🔒 | `"Debe completar su registro de poliza (Onboarding)..."` |
| GET | `/v1/cliente/siniestros` | **409** 🔒 | `"El usuario no tiene un perfil de cliente..."` |
| GET | `/v1/cliente/siniestros/{id}` | **409** 🔒 | Ídem |
| POST | `/v1/cliente/siniestros` | **409** 🔒 | `"Debe completar su registro de poliza (Onboarding) antes de reportar un siniestro."` |
| POST | `/v1/cliente/siniestros/{id}/imagenes` | **422** ⚠️ | Requiere campo multipart **`file`** — la app ya usa `file` ✅ correcto |
| GET | `/v1/cliente/consentimientos` | **405** ❌ | `Method Not Allowed` — la constante existe en la app (`clienteConsentimientos`) pero el backend no expone GET |

### Ajustador v1 (RBAC con rol Cliente)

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| GET | `/v1/ajustador/perfil` | **403** ✅ | `"Acceso denegado. Rol requerido: Ajustador."` |
| GET | `/v1/ajustador/asignaciones` | **403** ✅ | Ídem — RBAC funciona correctamente |

### Proxy Backend → IA

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/v1/ia/predict` | **502** ❌ | `error code: 502` — el backend **no alcanza el IA Service** |

## 🐛 Bugs y breaking changes detectados

### 1. `register` devuelve 500 pero persiste el usuario
El endpoint crea la cuenta (verificado: login inmediato funciona) pero responde 500. Probable fallo en un paso posterior al commit (envío de email o inicialización de perfil). **La app debe manejar el caso: si register falla con 500, el usuario puede existir.**

### 2. BREAKING: `confirmar-datos` exige datos del vehículo
El backend ahora requiere `vehiculo_marca`, `vehiculo_modelo`, `vehiculo_anio`, `vehiculo_placas` además de los 3 campos que la app envía. **Con el DTO actual, el onboarding nunca podrá confirmar (422).**
- ✅ Mitigación lista: la Fase 2 de la integración IA ya extrae estos 4 campos del OCR (`OnboardingState.vehiculoMarca/Modelo/Anio/Placas`).
- 🔧 Acción pendiente: agregarlos a `ConfirmDataRequestDto` y al método `confirm()`.

### 3. Proxy backend→IA completamente roto
`/v1/ia/*` → 502 y `/v1/cliente/onboarding/ocr` → 400 (wrap de 502). **Valida la decisión de la Fase 2**: la app ahora llama al IA Service directamente (`ia.actividades.icu`) sin pasar por el backend.

### 4. Usuarios auto-registrados no pueden completar onboarding
`confirmar-datos` y `consentimiento` fallan con "Perfil de cliente no encontrado/inicializado". El modelo de negocio espera que la **aseguradora** cree al cliente (con `primer_cambio_password: true`). Un usuario auto-registrado queda en limbo: puede loguearse pero no tiene perfil. **Definir si el registro público debe estar habilitado o si falta un endpoint de auto-inicialización de perfil.**

### 5. `recovery/verify` usa `usuario_id`, no `email`
El contrato difiere del típico flujo email+code. La app aún no implementa recovery, pero cuando lo haga debe obtener `usuario_id` primero.

### 6. `GET /v1/cliente/consentimientos` no existe (405)
La constante está declarada en `api_constants.dart` pero el backend no la soporta como GET. Eliminar o corregir.

## Impacto en la app Flutter

| Flujo de la app | Estado backend | Evaluación |
|---|---|---|
| Login + primer cambio de contraseña | ✅ Funciona | Flujo completo verificado (flag se limpia tras PATCH) |
| Registro | ⚠️ 500 engañoso | La app ya maneja Failure; pero el usuario creado puede reintentar login |
| Onboarding OCR | ❌ Proxy roto | **Ya mitigado** — Fase 2 usa IA Service directo |
| Onboarding confirmar | ❌ 422 garantizado | **Acción requerida**: enviar los 4 campos de vehículo (ya extraídos por IA OCR) |
| Onboarding consentimiento | 🔒 Gate de perfil | Depende del punto 4 (perfil inexistente) |
| Home / vehículos / siniestros | 🔒 409 claro | La app muestra error legible; correcto |
| Reportar siniestro + fotos | 🔒 409 claro | Campo multipart `file` coincide con la app ✅ |
| Push (device-token) | ✅ 201 | Listo para FCM |
| RBAC ajustador | ✅ 403 correcto | Sin fuga de acceso |

## Acciones recomendadas (prioridad)

1. **P0 — App:** agregar `vehiculo_marca/modelo/anio/placas` a `ConfirmDataRequestDto` y a `OnboardingController.confirm()` (los datos ya están en el estado tras el OCR IA).
2. **P0 — Backend:** arreglar `register` (500 tras crear usuario) o devolver 201 con warning.
3. **P1 — Backend:** resolver el limbo de usuarios auto-registrados (auto-crear perfil cliente en register, o deshabilitar registro público).
4. **P1 — Backend:** arreglar o eliminar el proxy `/v1/ia/*` (la app ya no lo necesita).
5. **P2 — App:** quitar la constante `clienteConsentimientos` (405) o alinear con el contrato real.
6. **P2 — Backend:** documentar el flujo `recovery` con `usuario_id` en el OpenAPI.
