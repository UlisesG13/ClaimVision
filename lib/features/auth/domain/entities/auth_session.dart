import 'user_role.dart';

/// Sesión autenticada del usuario. Entidad de negocio pura (sin Flutter, sin
/// `fromJson`). Se construye a partir de la respuesta de login/registro y se
/// persiste de forma segura para sobrevivir reinicios de la app.
class AuthSession {
  const AuthSession({
    required this.token,
    required this.usuarioId,
    required this.email,
    required this.rol,
    this.aseguradoraId,
  });

  /// Token JWT de acceso (Bearer).
  final String token;

  final String usuarioId;
  final String email;
  final UserRole rol;

  /// Aseguradora asociada. `null` para Administrador_Global y Cliente.
  final String? aseguradoraId;

  AuthSession copyWith({
    String? token,
    String? usuarioId,
    String? email,
    UserRole? rol,
    String? aseguradoraId,
  }) {
    return AuthSession(
      token: token ?? this.token,
      usuarioId: usuarioId ?? this.usuarioId,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      aseguradoraId: aseguradoraId ?? this.aseguradoraId,
    );
  }
}
