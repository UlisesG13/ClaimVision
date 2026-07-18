import '../entities/auth_session.dart';

/// Contrato de autenticación. La capa de presentación depende de esta
/// interfaz, nunca de la implementación concreta en `data/`.
///
/// Todos los métodos lanzan un `Failure` (de `core/errors/failures.dart`) ante
/// un error; en caso de éxito devuelven la entidad correspondiente.
abstract interface class AuthRepository {
  /// Inicia sesión con correo y contraseña. Persiste la sesión de forma segura.
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario. El backend devuelve un token (auto-login), por
  /// lo que la sesión queda iniciada y persistida al terminar.
  Future<AuthSession> register({
    required String nombre,
    required String email,
    required String password,
  });

  /// Recupera la sesión guardada en el dispositivo, o `null` si no hay ninguna.
  Future<AuthSession?> getStoredSession();

  /// Verifica contra el backend si el token guardado sigue siendo válido.
  /// Devuelve `true` si es válido, `false` si expiró/no es válido (401/403).
  /// Ante un error de red devuelve `true` (no se cierra sesión sin certeza).
  Future<bool> verifySession();

  /// Cierra sesión: borra el token y los datos sensibles del almacenamiento.
  Future<void> logout();

  /// Cambia la contraseña del usuario autenticado.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Registra el FCM token del dispositivo en el backend.
  Future<void> registerDeviceToken(String token);
}
