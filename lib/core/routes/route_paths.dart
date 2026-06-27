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

  /// Detalle de un siniestro. Usar [detalleSiniestroDe] para construir la ruta.
  static const String detalleSiniestro = '/siniestro/:id';
  static String detalleSiniestroDe(String id) => '/siniestro/$id';
}
