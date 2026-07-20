# Pruebas IA Service — ClaimVision

- **Fecha:** 2026-07-19
- **Base URL:** `https://ia.actividades.icu`
- **Versión del servicio:** 3.5.0 (confirmada vía `GET /`)
- **Herramienta:** curl + PowerShell (archivos de prueba generados localmente)
- **Contexto:** verificación de los endpoints consumidos por la app Flutter tras la integración IA (Fases 1–4)

## Resumen

| Estado | Cantidad | Endpoints |
|--------|----------|-----------|
| ✅ OK (2xx) | 12 | `/`, `/docs`, health v2*, history v1/v2/ocr/nlp, nlp detail, ocr base, transcribir, transcribir status, retrain v2 (validación 422) |
| ❌ 500 | 8 | health v1, predict v1, predict v2, retrain v1, ocr extract-ine, ocr extract-poliza, ocr extract-and-validate, nlp analizar |
| ⚠️ Parcial | 2 | health v2 (200 pero modelo sin clases), transcribir (job creado pero falla downstream) |

\* con salvedades, ver detalle.

## Resultados detallados

### General

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| GET | `/` | **200** ✅ | `{"service":"ClaimVision IA Service","version":"3.5.0","status":"running"}` |
| GET | `/docs` | **200** ✅ | Swagger UI disponible |

### Health

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| GET | `/api/v1/health` | **500** ❌ | `Internal Server Error` — modelo no supervisado roto |
| GET | `/api/v2/health` | **200** ⚠️ | `{"status":"ok","model_loaded":true,"device":"cpu","num_classes":0,"class_names":[]}` — reporta modelo cargado **pero con 0 clases**; contradictorio con el historial (class_id 0–5) |

### Predict v1 (No Supervisado)

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/api/v1/predict` | **500** ❌ | Falla con JPG sintético (640×480) **y con foto real** (48 KB). La inferencia está caída |
| GET | `/api/v1/history?page=1&limit=5` | **200** ✅ | 5 registros reales (Abolladura, Rayadura, Rotura_Cristal) |
| POST | `/api/v1/retrain` | **500** ❌ | Crashea incluso sin body (debería dar 422 como v2) |

### Predict v2 (Supervisado ResNet18)

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/api/v2/predict` | **500** ❌ | Falla con JPG sintético **y con foto real**. Consistente con `num_classes: 0` del health |
| GET | `/api/v2/history?page=1&limit=5` | **200** ✅ | 9 registros totales; últimas predicciones 2026-07-16 (Faro_roto 99.84%, Rotura_Cristal 96.75%) — el modelo **sí funcionó antes** |
| POST | `/api/v2/retrain` | **422** ✅ | Validación correcta: `labels` y `files` requeridos |
| GET | `/api/v2/retrain/{job_id}` | **404** ✅ | `{"detail":"Job no encontrado"}` — manejo de error correcto |

### OCR

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/api/v1/ocr` | **200** ✅ | PDF válido → `{"id":"8c7d1b1d-...","text":"","page_count":0}` |
| POST | `/api/v1/ocr/extract-ine` | **500** ❌ | Crashea con PDF vacío (sin contenido extraíble) |
| POST | `/api/v1/ocr/extract-poliza` | **500** ❌ | Ídem |
| POST | `/api/v1/ocr/extract-and-validate` | **500** ❌ | Ídem (campos `poliza` + `ine`) |
| GET | `/api/v1/ocr/history?page=1&limit=5` | **200** ✅ | 72 registros totales |

> Nota: los `extract-*` ya fallaban en la corrida del 2026-07-17 con archivos sin contenido. Pendiente probar con documentos reales (INE/póliza legibles); no se descarta que el 500 sea "crash al no encontrar campos" en vez de servicio caído.

### NLP

| Método | Endpoint | HTTP | Resultado |
|--------|----------|------|-----------|
| POST | `/api/v1/nlp/analizar` | **500** ❌ | **Falla con cualquier texto** (probado: narración larga, frase simple, JSON por archivo). Bug conocido desde 2026-07-17, sigue sin corregir |
| POST | `/api/v1/nlp/transcribir` | **200** ✅ | Acepta audio (WAV/MP3) → `{"job_id":"...","status":"pending","progress":0}`. Requiere `Content-Type` de audio explícito (`audio/mpeg`, `audio/wav`); con `application/octet-stream` rechaza 400 `"El archivo debe ser un audio"` |
| GET | `/api/v1/nlp/transcribir/status/{job_id}` | **200** ✅ | Responde bien, pero el job termina en `status:"failed"` con `error:"All connection attempts failed"` — **el backend de Whisper es inalcanzable desde el IA Service** (falla a los ~10 s, progress 60) |
| GET | `/api/v1/nlp/history?page=1&limit=5` | **200** ✅ | 1 registro (Prueba.mp3, 4.08 s, 0 entidades) |
| GET | `/api/v1/nlp/{id}` | **200** ✅ | Detalle completo de transcripción existente |

## 🐛 Bugs activos en el IA Service

1. **`POST /api/v1/nlp/analizar` → 500 con cualquier entrada.** El pipeline del LLM (extracción de entidades) está caído. Persiste desde el 17-jul.
2. **`POST /api/v1/predict` y `/api/v2/predict` → 500 con imágenes válidas.** Ninguno de los dos modelos infiere. El health de v2 es engañoso: dice `model_loaded: true` pero `num_classes: 0`.
3. **`GET /api/v1/health` → 500.** El healthcheck del modelo v1 crashea.
4. **Whisper (transcripción) inalcanzable:** jobs se crean pero fallan con `All connection attempts failed` al ~60% de progreso. Problema de red/credenciales del worker, no del endpoint.
5. **`POST /api/v1/retrain` → 500 sin body** (debería validar 422 como hace v2).
6. **`ocr/extract-*` → 500 con PDFs sin contenido real.** Posible crash por campos faltantes en vez de error controlado 4xx.

## Impacto en la app Flutter (integración Fases 1–4)

| Funcionalidad de la app | Endpoint usado | Estado real hoy | Comportamiento de la app |
|---|---|---|---|
| Grabación de voz + transcripción (narración) | `transcribir` + `status` | ⚠️ Job creado, falla downstream | La app muestra el audio como "enviado", el polling recibe `failed` y muestra snackbar de error. **Manejado** |
| Análisis del relato (IA) | `nlp/analizar` | ❌ 500 siempre | `analizarTexto()` captura el fallo, `errorMessage` → snackbar; tarjeta queda vacía. **Manejado, sin crash** |
| Predicción de daño por foto (badges) | `v2/predict` | ❌ 500 siempre | `_predecirDano()` hace catch silencioso; la foto sube igual, solo sin badge IA. **Degradación elegante** |
| Onboarding OCR (cédula + póliza) | `ocr/extract-and-validate` | ❌ 500 con PDF vacío | Error → "No se pudieron analizar los documentos. Verifica que las fotos sean legibles." **Requiere retest con docs reales** |
| Tab "Análisis IA" (historiales) | `v2/history`, `nlp/history` | ✅ Funciona | Muestra datos reales del servicio |
| Tarjeta de estado IA (perfil) | `health` v1 + v2 | ⚠️ v1 caído, v2 engañoso | Mostrará "IA: modelo supervisado activo" (v2 reporta `model_loaded: true`) aunque predict falle — el health del servidor no es confiable |
| Health al iniciar la app | `health` v1 + v2 | ídem | Warm-up no bloquea el arranque (try/catch) |

## Conclusión

La **integración del lado de la app está completa y es resiliente**: todos los flujos capturan errores del servicio y degradan sin crashear (snackbar, badge ausente, tarjeta vacía). 

El **IA Service tiene 3 subsistemas caídos**: inferencia de imágenes (v1 y v2), análisis NLP por LLM y el worker de Whisper. Los historiales y el OCR básico funcionan. Se recomienda:

1. Revisar logs del servicio para `predict` (probable modelo no cargado al arrancar, cf. `num_classes: 0`).
2. Revisar conectividad/credenciales del worker Whisper y del LLM de `nlp/analizar`.
3. Hacer el healthcheck v2 honesto (fallar si `num_classes == 0`).
4. Retest de `ocr/extract-and-validate` con documentos reales antes de culpar al servicio.
