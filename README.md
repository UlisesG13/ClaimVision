# ClaimVision — 

> **Propósito de este archivo.** Este README es la fuente de verdad para que el agente de IA (opencode) entienda el proyecto y genere código que respete la arquitectura, el flujo de negocio y las convenciones definidas. **No es documentación de presentación.** Antes de implementar cualquier cosa, el agente debe leer este archivo completo y ajustarse a estas reglas. Si una petición contradice estas reglas, el agente debe señalarlo en lugar de romper la arquitectura.

---

## 1. Qué es ClaimVision

App móvil (Flutter) de peritaje vehicular asistido por visión por computadora. Tras un choque, el **cliente** fotografía el daño y narra qué pasó; el sistema genera un **informe preliminar** (zonas dañadas, tipo, severidad, costo estimado). Ese informe lo recibe la **aseguradora**, que asigna un **ajustador** para validarlo en sitio; una vez validado, la aseguradora lo envía a un **taller** para el presupuesto y la reparación, hasta la entrega del vehículo.

El acceso es **cerrado y jerárquico**: nadie se registra solo. El **administrador** da de alta a las aseguradoras; cada aseguradora da de alta a sus ajustadores, talleres y clientes.

**Regla de oro del dominio:** la evaluación de la IA es **siempre preliminar**, nunca un dictamen. Un ajustador la valida y corrige en persona. Ninguna pantalla ni mensaje debe dar a entender que la IA decide sola.

---

## 2. Stack Técnico Obligatorio

> ⚠️ **REGLA DE ORO:** No cambiar ninguna tecnología ni introducir dependencias pesadas nuevas (otros gestores de estado, routers o clientes HTTP) sin autorización previa. Si una tarea parece requerirlo, se debe proponer y justificar primero.

---

### 🛠️ Arquitectura y Core del Sistema

*   **Framework:** `Flutter (Dart)` | Desarrollo multiplataforma nativo para Android e iOS.
*   **Patrón de Arquitectura:** `Clean Architecture` estructurado estrictamente por *features*. Cada una debe respetar las capas independientes:
    *   📁 `data/`
    *   📁 `domain/`
    *   📁 `presentation/`
*   **Inyección de Dependencias:** Centralizada exclusivamente a través del contenedor en `core/di/`.

---

### 🚦 Estado, Navegación y Persistencia

*   **Gestión de Estado:** Regla de uso mixto según complejidad (ver Sección 5):
    *   **Simple:** `setState` / `Provider` (estados locales o efímeros).
    *   **Complejo:** `Riverpod` (estados globales, asíncronos o flujos críticos).
*   **Navegación:** `GoRouter` (rutas fuertemente tipadas y manejo declarativo).
*   **Almacenamiento Seguro:** `flutter_secure_storage` implementado a través de `core/services/` (para persistencia de tokens de sesión y datos sensibles).

---

### 🌐 Conectividad y Servicios Integrados

*   **Arquitectura Backend:** `Backend Propio (Python / FastAPI)` consumido vía API REST. 
*   **Cliente HTTP:** `Dio` configurado con interceptores globales en `core/network/` para:
    *   Inyección de tokens OAuth.
    *   Estrategias de *Token Refresh* automático.
    *   Manejo y tipado unificado de errores de red.
*   **Notificaciones Push:** Servicio centralizado en `core/services/` dedicado prioritariamente al flujo de órdenes de entrega y alertas en tiempo real.

## 3. Arquitectura de carpetas (respetar al pie de la letra)

```
lib/
├── core/                         # CAPA TRANSVERSAL (Infraestructura base)
│   ├── constants/                # Valores fijos (URLs base, llaves, claves de almacenamiento)
│   ├── errors/                   # Excepciones y Failures personalizados
│   ├── di/                       # Gestión de dependencias (registro de repos, datasources, usecases)
│   ├── routes/                   # Configuración de rutas (GoRouter) + guards por rol
│   ├── network/                  # Cliente HTTP (Dio), interceptores OAuth/Tokens, manejo de respuestas
│   ├── services/                 # Servicios globales (Secure Storage, GPS/geolocalización, Push)
│   └── theme/                    # Tema global: colores, tipografía, estilos
│
├── features/                     # CAPA DE MÓDULOS (una carpeta por funcionalidad)
│   └── [nombre_funcionalidad]/   # p. ej. auth, incident, peritaje, assignment, workshop, admin
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── local/        # Persistencia local (cache, secure storage)
│       │   │   └── remote/       # Llamadas a la API REST del backend
│       │   ├── dtos/             # Data Transfer Objects (JSON <-> Dart)
│       │   ├── mappers/          # Conversión DTO -> Entity y Entity -> DTO
│       │   └── repositories/     # Implementación de los contratos del domain
│       │
│       ├── domain/               # LÓGICA DE NEGOCIO PURA (sin imports de Flutter)
│       │   ├── entities/         # Modelos de negocio puros
│       │   ├── repositories/     # Contratos (interfaces abstractas)
│       │   └── usecases/         # Una acción de negocio por clase
│       │
│       └── presentation/
│           ├── pages/            # Pantallas completas
│           ├── state/            # Gestores de estado (Provider o Riverpod, según complejidad)
│           └── widgets/          # Widgets reutilizables solo dentro de este feature
│
├── shared/
│   ├── widgets/                  # Botones, inputs, modales compartidos entre features
│   └── utils/                    # Utilidades compartidas (validadores, formateadores, helpers)
│
├── main.dart                     # Punto de entrada
└── app.dart                      # Configuración de app: rutas, navegación, tema
```

### Reglas de dependencia entre capas (estricto)

- `presentation` → puede usar `domain` (usecases, entities). **Nunca** importa `data` directamente.
- `domain` → **no importa nada de Flutter ni de `data`**. Es Dart puro. Define entities, contratos y usecases.
- `data` → implementa los contratos de `domain`. Convierte DTOs a Entities con los **mappers**. Nunca expone DTOs hacia arriba.
- El flujo de datos siempre es: **UI → usecase → repository (contrato) → repository impl → datasource → API REST**, y de regreso **DTO → mapper → entity → UI**.
- `core/` y `shared/` pueden ser usados por cualquier feature; los features **no** dependen entre sí directamente (si necesitan compartir, va en `shared/` o se coordina vía `core/`).

---

## 4. Estructura de Features (Mapa de Módulos)

> 📁 **Regla de Directorios:** Cada módulo listado a continuación debe crearse dentro de la carpeta `features/` siguiendo estrictamente la estructura interna de tres capas: `data / domain / presentation`.

---

### 🔐 Módulo Core (Acceso y Cuenta)

*   ### `auth`
    *   **Responsabilidad:** Gestión de acceso, onboarding inicial, aviso de privacidad, configuración y login por consentimiento biométrico, recuperación de contraseña, gestión del perfil y cierre de sesión.
    *   **Roles:** `[Todos los Roles]`

---

### 🚗 Flujo Operativo del Siniestro

*   ### `incident`
    *   **Responsabilidad:** Reporte y alta del siniestro en tiempo real. Incluye captura de geolocalización, toma de fotografías con validación de calidad integrada, narración del hecho (vía voz a texto o escrito), envío preliminar al sistema y monitoreo del estado del reporte.
    *   **Roles:** `[Cliente]`

*   ### `peritaje`
    *   **Responsabilidad:** Visualización técnica del siniestro. Mapeo de daños marcados sobre la unidad, cálculo de severidad e importes estimados. Soporta comportamiento dinámico de interfaces: *Modo Lectura* y *Modo Edición* según permisos.
    *   **Roles:** `[Cliente]` `[Ajustador]` `[Aseguradora]` `[Taller]`

*   ### `assignment`
    *   **Responsabilidad:** Coordinación logística del siniestro. Bandejas de entrada compartidas, asignación inteligente de ajustador en campo, direccionamiento a talleres mecánicos, seguimiento del ciclo de vida del incidente, flujos de validación/corrección del ajustador y confirmación final del peritaje.
    *   **Roles:** `[Aseguradora]` `[Ajustador]`

---

### 🛠️ Flujo de Reparación y Entrega

*   ### `workshop`
    *   **Responsabilidad:** Operación interna del centro de reparación. Bandeja de entrada de vehículos, visualización de peritajes disociados, carga y desglose de presupuestos, marcado de trabajo concluido y panel de control con soporte multitenant (atención multi-aseguradora).
    *   **Roles:** `[Taller]`

*   ### `closure`
    *   **Responsabilidad:** Cierre administrativo y físico del siniestro. Automatización del flujo: Trabajo concluido ➔ Validación de calidad por la Aseguradora ➔ Generación de orden de entrega de la unidad ➔ Notificación push automatizada al cliente final.
    *   **Roles:** `[Aseguradora]` `[Taller]` `[Cliente]`

---

### ⚙️ Administración General

*   ### `admin`
    *   **Responsabilidad:** Panel de control maestro (*Backoffice*). Alta y gestión de empresas aseguradoras, control de planes y suscripciones, verificación de cuentas, procesos de baja de datos con respaldo íntegro en servidor y logs de auditoría técnica.
    *   **Roles:** `[Administrador]`

> El **componente "Peritaje"** se centraliza en el feature `peritaje` y se reutiliza. Tiene dos modos: **solo lectura** (cliente, aseguradora, taller) y **editable** (ajustador). No duplicar esta vista en cada feature.

---

## 5. Regla de gestión de estado (IMPORTANTE)

La elección del gestor de estado **depende de la complejidad de la pantalla/feature**. El agente debe aplicar esta regla, no elegir al azar:

### Usar `setState` o `Provider` (simple) cuando:
- La pantalla tiene estado local y acotado (un formulario, un toggle, un contador, mostrar/ocultar).
- No hay flujos asíncronos complejos ni múltiples fuentes de estado coordinándose.
- Ejemplos en este proyecto: pantallas de perfil, formularios de alta simples, aceptar aviso de privacidad, pantallas informativas.

### Usar `Riverpod` (complejo) cuando:
- Hay estado compartido entre varias pantallas o que sobrevive a la navegación.
- Hay flujos asíncronos con varios estados (cargando / éxito / error / vacío) y reintentos.
- Hay lógica de negocio reactiva, dependencias entre providers, o datos que se actualizan en tiempo real.
- Ejemplos en este proyecto: flujo de reportar siniestro (cámara + geo + validación + narración + envío), bandejas de incidentes con estado, monitoreo de estado del siniestro, validación/corrección del peritaje, flujo de cierre con notificaciones.

### Convención al implementar
- El estado de cada feature vive en `features/<feature>/presentation/state/`.
- Si usas Riverpod: providers y notifiers en ese folder; nombrarlos `<algo>_provider.dart` / `<algo>_notifier.dart`.
- Si usas Provider/setState: el `ChangeNotifier` o el estado local en ese mismo folder.
- **No mezclar los dos gestores dentro de una misma pantalla.** Una pantalla es simple (Provider/setState) o compleja (Riverpod), no ambas.
- Cuando tengas duda de si algo es "simple" o "complejo", trátalo como complejo (Riverpod) si involucra llamadas a la API con manejo de estados; trátalo como simple si es solo UI local.

---

## 6. Reglas del backend y la red

- El backend es **propio (Python / FastAPI) y se consume por REST**. Toda llamada pasa por el cliente Dio configurado en `core/network/`.
- La URL base y endpoints se definen en `core/constants/`. **No hardcodear URLs** dentro de los datasources.
- Autenticación por **tokens (OAuth/JWT)**: el interceptor en `core/network/` añade el token, maneja el refresh y los errores 401.
- Los tokens y datos sensibles se guardan **solo** con `flutter_secure_storage` (vía `core/services/`), nunca en SharedPreferences ni en texto plano.
- Cada `remote datasource` recibe el cliente HTTP por inyección (desde `core/di/`), no crea su propia instancia.
- Las respuestas de la API se parsean a **DTOs**, y los DTOs se convierten a **Entities** con mappers antes de salir de la capa `data`.
- Manejo de errores: las excepciones técnicas se capturan en `data` y se traducen a `Failures` (definidos en `core/errors/`) que la UI entiende. La UI nunca recibe una excepción cruda de Dio.

---

## 7. Reglas de privacidad y seguridad (del dominio, obligatorias)

Estas reglas vienen de los requerimientos y **no son negociables** al implementar:

1. **Aviso de privacidad antes del onboarding.** El cliente no puede avanzar en el onboarding hasta confirmar la lectura del Aviso de Privacidad. Implementar como gate que bloquea la navegación.
2. **Consentimiento biométrico explícito.** Antes de activar huella/rostro/voz, el sistema debe registrar el consentimiento verificable del usuario.
3. **Datos disociados para el taller.** En cualquier vista del rol Taller, **nunca** mostrar datos personales del cliente (nombre, identificación, teléfono, póliza, dirección). El taller solo ve datos técnicos del vehículo (marca, modelo, año, placas/serie) y los daños. Esto se respeta tanto en la UI como en lo que se pide a la API.
4. **El taller nunca accede a datos de contacto del cliente** en ningún punto del ciclo del siniestro.
5. **Bajas ARCO.** Dar de baja un usuario lo deja en estado "Bloqueado por ARCO": credenciales deshabilitadas de inmediato y datos ocultos de las vistas ordinarias.
6. **Acceso por rol.** Cada rol ve solo lo suyo; un ajustador ve solo sus casos asignados, una aseguradora solo los de su organización. Aplicar guards de rol en `core/routes/`.

---

## 8. Flujo de la Aplicación (Referencia de Negocio)

El siguiente diagrama documenta el flujo operativo completo dividido por roles. Utiliza este mapa para entender la interconexión de pantallas, la delegación de responsabilidades y la progresión del siniestro en el sistema.

```mermaid
graph TD
    INICIO([Inicio de Sesión Segura]) --> ROL{¿Qué Rol?}

    %% CLIENTE
    ROL -->|Cliente| C_LOGIN{¿Primer Login u Onboarding?}
    C_LOGIN -->|Sí| C_AVISO{¿Acepta Aviso de Privacidad y Biométricos?}
    C_AVISO -->|No| C_CAN[Registro Denegado / Fin]
    C_AVISO -->|Sí| C_OCR[Escanear Documentos e ID vía OCR]
    C_OCR --> C_DASH[Dashboard Cliente]
    C_LOGIN -->|No| C_DASH
    C_DASH --> C_REP[Reportar Siniestro]
    C_REP --> C_GEO[Capturar Geolocalización Inicial]
    C_GEO --> C_CAM[Cámara Activa: Captura de Fotografías]
    C_CAM --> C_VALIA{¿Validación de Calidad IA Exitosa?}
    C_VALIA -->|No| C_CAM
    C_VALIA -->|Sí| C_NARR[Narración del Incidente: Voz o Texto]
    C_NARR --> C_ENV[Enviar Reporte Preliminar a Aseguradora]
    C_ENV --> C_EST[Monitorear Estado del Siniestro]
    C_EST --> C_NOTIF{¿Notificación: Auto Listo?}
    C_NOTIF -->|No| C_EST
    C_NOTIF -->|Sí| C_RECIBO([Recoger Vehículo / Fin])

    %% AJUSTADOR
    ROL -->|Ajustador| AJ_DASH[Dashboard Ajustador]
    AJ_DASH --> AJ_ASIG[Ver Casos Asignados]
    AJ_ASIG --> AJ_SITIO[Inspección Presencial en Sitio]
    AJ_SITIO --> AJ_DICT[Revisar y Corregir Peritaje de IA]
    AJ_DICT --> AJ_ENV[Confirmar y Bloquear Peritaje Definitivo]
    AJ_ENV --> AS_REV

    %% ASEGURADORA
    ROL -->|Aseguradora| AS_DASH[Dashboard Aseguradora]
    AS_DASH --> AS_CAT[Gestión Jerárquica: Alta de Ajustadores y Clientes]
    AS_DASH --> AS_MON[Recibir Alertas de Incidentes]
    AS_MON --> AS_ASIG_AJ[Asignar Incidente a Ajustador]
    AS_REV[Revisar Expediente Validado] --> AS_ENVIAR_TALLER[Seleccionar y Enviar Caso a Taller]
    AS_ENVIAR_TALLER -->|Exclusión de Datos Personales| T_REC
    AS_MON_C[Monitorear Presupuesto del Taller] --> AS_AUT_FIN{¿Presupuesto Aceptado?}
    AS_AUT_FIN -->|No: Rechazado| T_COT
    AS_AUT_FIN -->|Sí: Aprobado| T_REP[Taller Inicia Reparación]
    T_FIN_REP[Taller Marca: Trabajo Concluido] --> AS_AUT_FIN2{¿Aseguradora Valida Reparación?}
    AS_AUT_FIN2 -->|Sí| AS_ORDEN_ENTREGA[Emitir Orden de Entrega y Notificar al Cliente]
    AS_ORDEN_ENTREGA --> C_NOTIF

    %% TALLER
    ROL -->|Taller| T_DASH[Dashboard Taller]
    T_DASH --> T_REC[Recibir Orden con Datos Técnicos Disociados]
    T_REC --> T_COT[Elaborar o Corregir Presupuesto]
    T_COT --> AS_MON_C
    T_REP --> T_FIN_REP

    %% ADMINISTRADOR
    ROL -->|Administrador| AD_DASH[Console Admin Global]
    AD_DASH --> AD_ARCO[Gestionar Bloqueos ARCO y Contratos]
    AD_ARCO --> FIN_H([Fin de Jornada / Archivo])

## 9. Convenciones de código

- **Nombres de archivos:** `snake_case.dart`. Clases en `PascalCase`. Variables y métodos en `camelCase`.
- **Un usecase por archivo**, nombrado por la acción: `report_incident.dart`, `assign_adjuster.dart`, `confirm_peritaje.dart`.
- **DTOs** terminan en `_dto.dart` y exponen `fromJson` / `toJson`. **No** poner lógica de negocio en DTOs.
- **Entities** son inmutables y puras (sin `fromJson`, sin imports de Flutter).
- **Mappers** son funciones/clases puras que convierten DTO ↔ Entity. Viven en `data/mappers/`.
- **Strings de UI en español** (la app es en español, con lenguaje coloquial mexicano en lo que ve el cliente).
- **Sin lógica de negocio en los widgets.** Los widgets solo pintan y delegan al estado/usecases.
- Manejar siempre los cuatro estados de una operación asíncrona: cargando, éxito, vacío y error (sin perder datos ya capturados ante un error).
- Comentarios y nombres descriptivos; preferir claridad sobre brevedad.

---

## 10. Cómo debe trabajar el agente en este repo

1. **Lee este README antes de cada tarea.** Es la fuente de verdad.
2. **Respeta la arquitectura de carpetas y las reglas de dependencia** entre capas (sección 3). No tomes atajos que crucen capas.
3. **Aplica la regla de estado por complejidad** (sección 5): Provider/setState para lo simple, Riverpod para lo complejo. Si dudas, justifícalo brevemente en el código o pregunta.
4. **Coloca cada cosa en su feature** (sección 4). No crees pantallas sueltas fuera de la estructura.
5. **Cumple las reglas de privacidad** (sección 7) sin excepción, sobre todo la disociación de datos del taller.
6. Al crear un feature nuevo, **genera la estructura completa** (data/domain/presentation con sus subcarpetas), aunque algunas queden mínimas al inicio.
7. Si una petición **contradice** estas reglas o la arquitectura, **dilo y propón la forma correcta** en vez de implementarla rompiendo el diseño.
8. Antes de añadir una dependencia nueva, verifica que no se pueda resolver con el stack ya definido (sección 2).
9. Mantén el código **en español** en lo que ve el usuario y en los comentarios.
