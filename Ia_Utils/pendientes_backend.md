# Pendientes de Backend — ClaimVision (2026-07-23)

> Bugs verificados **empíricamente** contra el backend real
> (`https://api.actividades.icu/api`) desde el frontend. Cada uno incluye la
> reproducción y la evidencia. **Ninguno es un bug de la app Flutter** — el
> cliente sube bien y recibe 200; las fallas ocurren en los workers/servicios de
> IA del backend.

---

## 🔴 P0 — Transcripción de voz falla con "Connection error"

**Endpoint:** `POST /api/v1/ia/nlp/transcribir` → `GET /api/v1/ia/nlp/transcribir/status/{job_id}`

**Síntoma:** el job se acepta (llega a `progress: 10`) y luego termina en
`status: "failed"` con `error: "Connection error."` — **con cualquier audio y
cualquier content-type**.

### Reproducción (verificada 2026-07-23)

Probado con un WAV válido de 2s (tono 440Hz, 16kHz mono) y repetido con
`audio/wav`, `audio/mpeg` y `audio/mp4`:

```
POST /v1/ia/nlp/transcribir            → 200 {"job_id":"...","status":"pending","progress":0}
GET  /v1/ia/nlp/transcribir/status/... → 200 {"status":"failed","progress":10,
                                              "result":null,"error":"Connection error."}
```

Los tres content-types dan el **mismo** resultado (`failed` en el 10%).

### Diagnóstico

El worker de transcripción recibe el archivo correctamente (sube 200, avanza a
10%), pero **falla al conectar con su proveedor upstream de speech-to-text**
(Whisper/OpenAI/servicio STT) → lanza `"Connection error."`.

### Qué revisar en el backend

- Conectividad/credenciales del worker hacia el servicio STT (API key vigente,
  URL, red de salida, timeout).
- Que el servicio STT esté arriba y accesible desde el contenedor del worker.
- Logs del worker de `nlp/transcribir` en el momento de la falla (progress 10).

### Estado del frontend

✅ Sin cambios pendientes. La app ya degrada con elegancia: si el job falla,
muestra *"No pudimos transcribir el audio. Escribe tu declaración manualmente."*
Apenas el STT vuelva a conectar, la transcripción funcionará **sin tocar la app**
(el camino de éxito `completed → result.texto` está intacto).

---

## 🔴 P1 — OCR `extract-poliza` responde 502

**Endpoint:** `POST /api/v1/ia/ocr/extract-poliza`

**Síntoma:** 502 Bad Gateway (único endpoint del bridge caído; el resto del OCR
opera). Detectado desde la ronda 9 y aún presente.

### Nota

El flujo de onboarding **no** depende de este endpoint: usa
`POST /api/v1/ia/ocr/extract-and-validate`, que **sí funciona** (verificado
2026-07-23: PDF de póliza + INE → 200 con extracción de `numero_poliza`, nombre,
etc.). Aun así conviene arreglar `extract-poliza` para dejar la superficie de IA
completa.

### Qué revisar

- Por qué el proxy/bridge devuelve 502 solo en esta ruta (¿timeout del servicio
  IA?, ¿ruta no montada?, ¿handler que crashea?).

---

## 🟡 P2 — `confirmar-datos` requiere `aseguradora_id` (posible NotNullViolation)

**Endpoint:** `POST /api/v1/cliente/onboarding/confirmar-datos`

**Síntoma reportado (ronda 9):** `NotNullViolation` en `aseguradora_id` — el DTO
que envía la app no incluye ese campo.

### Por qué importa

Si `confirmar-datos` falla, el onboarding del cliente **nunca cierra**
(`completed` no se pone en `true`), el botón "Confirmar y Vincular" lanza error y
la póliza no queda vinculada. Es el paso crítico del onboarding.

### Qué definir con el frontend

- ¿El `aseguradora_id` lo debe **derivar el backend** (desde la póliza/OCR o el
  usuario), o lo debe **enviar la app**? Lo natural es que el backend lo resuelva
  a partir de la póliza ya validada, no que el cliente lo mande.
- Confirmar el contrato final del DTO de `confirmar-datos`.

### Pendiente de verificación

Falta una prueba end-to-end de `confirmar-datos` con un onboarding real para
confirmar si el bug sigue vivo con el flujo actual de la app.

---

## Resumen

| # | Prioridad | Endpoint | Falla | ¿App? |
|---|-----------|----------|-------|-------|
| 1 | P0 | `nlp/transcribir` (status) | `failed: "Connection error."` en 10% | No |
| 2 | P1 | `ocr/extract-poliza` | 502 Bad Gateway | No |
| 3 | P2 | `cliente/onboarding/confirmar-datos` | NotNullViolation `aseguradora_id` | Por verificar |

**Todo lo demás del flujo verificado hoy funciona:** login, perfil, siniestros,
`ocr/extract-and-validate` (onboarding), subida de evidencias.
