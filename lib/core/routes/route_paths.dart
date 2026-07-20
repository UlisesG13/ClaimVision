/// Rutas centralizadas de la app. No escribir strings de ruta sueltos en las
/// pantallas: usar estas constantes con `context.go(...)` / `context.push(...)`.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/registro';

  // Cliente
  static const String onboarding = '/onboarding';
  static const String inicio = '/inicio';
  static const String historial = '/historial';
  static const String vehiculos = '/vehiculos';
  static const String perfil = '/perfil';
  // Wizard de reporte de siniestro (#5–#9)
  static const String reportar = '/reportar'; // #5 Vehículo
  static const String reportarUbicacion = '/reportar-ubicacion'; // #6
  static const String reportarNarracion = '/reportar-narracion'; // #7
  static const String reportarDano = '/reportar-dano'; // #8
  static const String reportarAnalisis = '/reportar-analisis'; // #9

  static const String notificaciones = '/notificaciones';
  static const String configuracion = '/configuracion';

  /// Detalle de un siniestro. Usar [detalleSiniestroDe] para construir la ruta.
  static const String detalleSiniestro = '/siniestro/:id';
  static String detalleSiniestroDe(String id) => '/siniestro/$id';

  // ── Ajustador ─────────────────────────────────────────────────────────
  static const String casos = '/casos';
  static const String casoDetalle = '/caso/:id';
  static String casoDetalleDe(String id) => '/caso/$id';
  static const String validacionPeritaje = '/caso/:id/validacion';
  static String validacionPeritajeDe(String id) => '/caso/$id/validacion';
  static const String firmaPeritaje = '/caso/:id/firma';
  static String firmaPeritajeDe(String id) => '/caso/$id/firma';
  static const String peritajeConfirmado = '/caso/:id/confirmado';
  static String peritajeConfirmadoDe(String id) => '/caso/$id/confirmado';
  static const String notificacionesAjustador = '/ajustador/notificaciones';

  // ── OCR / Documentos ────────────────────────────────────────────────────
  static const String capturaDocumentos = '/captura-documentos';

  // ── Seguridad ───────────────────────────────────────────────────────────
  static const String bloqueado = '/bloqueado';
}
