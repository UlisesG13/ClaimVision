# Paleta de Colores — ClaimVision Web

Extraída de la app Flutter (`lib/core/theme/app_colors.dart`, `app_theme.dart`) para mantener paridad visual en la plataforma web.

## Colores de marca

| Token | Hex | Uso |
|---|---|---|
| `blueprint` | `#0A1F3C` | Color primario. AppBar, textos principales, botón primario en dark mode, bordes de foco |
| `blueprintLight` | `#14305C` | Variante clara del primario. Gradientes (login), headers oscuros |
| `amber` | `#FEAD3B` | Color de acento. Botones primarios (light), íconos destacados, selección en bottom nav, links |
| `alert` | `#FF5A4D` | Errores, daños de severidad alta, estados fallidos |
| `success` | `#2EC27E` | Confirmaciones, daños de severidad baja, estados válidos |
| `background` | `#F7FAFD` | Fondo de pantallas (light mode) |
| `white` | `#FFFFFF` | Superficies, tarjetas, AppBar (light) |

## Texto (light mode)

| Token | Hex | Uso |
|---|---|---|
| `textPrimary` | `#0A1F3C` | Títulos, cuerpo principal (mismo valor que blueprint) |
| `textSecondary` | `#6B7280` | Subtítulos, labels secundarios |
| `textHint` | `#9CA3AF` | Placeholders, íconos deshabilitados, items no seleccionados |

## Bordes y superficies (light mode)

| Token | Hex | Uso |
|---|---|---|
| `borderLight` | `#E5E7EB` | Bordes de tarjetas, inputs, divisores |
| `surfaceCard` | `#FFFFFF` | Fondo de tarjetas |

## Dark mode

| Token | Hex | Uso |
|---|---|---|
| `darkBackground` | `#121212` | Fondo de pantallas |
| `darkSurface` | `#1E1E1E` | AppBar, bottom nav, superficies elevadas |
| `darkCard` | `#2D2D2D` | Fondo de tarjetas |
| `darkBorder` | `#3A3A3A` | Bordes y divisores |
| `darkTextPrimary` | `#F5F5F5` | Texto principal |
| `darkTextSecondary` | `#B0B0B0` | Texto secundario |
| `darkTextHint` | `#808080` | Placeholders, hints |

## Colores auxiliares (presentes en la app)

| Token | Hex | Uso |
|---|---|---|
| `accentBlue` | `#B4C7EC` | Texto sobre fondos oscuros (login, onboarding scan card, headers de ajustador) |
| `deepNavy` | `#000616` | Fondo de la tarjeta de escaneo OCR (onboarding) |
| `bannerNavy` | `#1A3A5C` | Fondo del banner de notificaciones in-app |
| `inputBorder` | `#C4C6CE` | Borde de inputs en formularios específicos (registro, reporte, casos) |
| `checkboxGreen` | `#009A60` | Checkboxes de consentimientos ARCO |
| `amberDark` | `#6D4400` | Texto sobre botones ámbar (contraste accesible en onboarding/registro) |

## Severidad de daños (semántico)

| Nivel | Token base | Hex |
|---|---|---|
| Bajo | `success` | `#2EC27E` |
| Medio | `amber` | `#FEAD3B` |
| Alto | `alert` | `#FF5A4D` |

## CSS — variables listas para usar

```css
:root {
  /* Marca */
  --blueprint: #0A1F3C;
  --blueprint-light: #14305C;
  --amber: #FEAD3B;
  --alert: #FF5A4D;
  --success: #2EC27E;
  --background: #F7FAFD;
  --white: #FFFFFF;

  /* Texto (light) */
  --text-primary: #0A1F3C;
  --text-secondary: #6B7280;
  --text-hint: #9CA3AF;

  /* Bordes y superficies (light) */
  --border-light: #E5E7EB;
  --surface-card: #FFFFFF;

  /* Dark mode */
  --dark-background: #121212;
  --dark-surface: #1E1E1E;
  --dark-card: #2D2D2D;
  --dark-border: #3A3A3A;
  --dark-text-primary: #F5F5F5;
  --dark-text-secondary: #B0B0B0;
  --dark-text-hint: #808080;

  /* Auxiliares */
  --accent-blue: #B4C7EC;
  --deep-navy: #000616;
  --banner-navy: #1A3A5C;
  --input-border: #C4C6CE;
  --checkbox-green: #009A60;
  --amber-dark: #6D4400;

  /* Severidad */
  --severity-low: #2EC27E;
  --severity-medium: #FEAD3B;
  --severity-high: #FF5A4D;
}
```

## Notas de implementación

- **Botón primario (light):** fondo `amber` `#FEAD3B`, texto `white`. En dark mode, texto `blueprint` `#0A1F3C` sobre ámbar.
- **Botón primario (onboarding/registro):** texto `amberDark` `#6D4400` sobre ámbar (mayor contraste).
- **Inputs:** fondo `white` (light) / `darkCard` (dark); borde enfocado `blueprint` 1.5px (light) / `amber` (dark).
- **Bottom nav:** seleccionado `amber`, no seleccionado `textHint` (light) / `darkTextHint` (dark).
- **Gradiente login:** `blueprintLight` → `blueprint`.
- **Opacidades usadas:** overlays negros al 35–54%, tintes de acento al 8–12% de alpha (badges, banners, estados).
- Radios de borde de referencia (no color, pero del mismo tema): 12px (`radiusMd`), 16px (`radiusLg`).
