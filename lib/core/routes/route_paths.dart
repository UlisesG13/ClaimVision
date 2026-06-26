/// Rutas centralizadas de la app. No escribir strings de ruta sueltos en las
/// pantallas: usar estas constantes con `context.go(...)` / `context.push(...)`.
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/registro';

  // Cliente
  static const String inicio = '/inicio';
  static const String perfil = '/perfil';
}
