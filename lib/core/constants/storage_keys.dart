/// Claves usadas en el almacenamiento seguro (`flutter_secure_storage`).
///
/// Nunca guardar tokens ni datos sensibles en SharedPreferences ni en texto
/// plano: todo pasa por estas claves vía `SecureStorageService`.
class StorageKeys {
  StorageKeys._();

  static const String token = 'cv_token';
  static const String usuarioId = 'cv_usuario_id';
  static const String email = 'cv_email';
  static const String rol = 'cv_rol';
  static const String aseguradoraId = 'cv_aseguradora_id';

  static String primerInicioPara(String userId) => 'cv_primer_inicio_$userId';

  /// Último usuario que inició sesión (para pre-cargar flags del login).
  static const String ultimoUsuarioId = 'cv_ultimo_usuario_id';

  /// Aviso de privacidad aceptado en el login por usuario.
  static String avisoAceptadoPara(String userId) => 'cv_aviso_aceptado_$userId';

  // ── Biometría ──────────────────────────────────────────────────────────
  static const String biometricEnabled = 'cv_biometric_enabled';
  static const String biometricEmail = 'cv_biometric_email';
  static const String biometricPassword = 'cv_biometric_password';

  // ── Tema ────────────────────────────────────────────────────────────────
  static const String themeMode = 'cv_theme_mode';
}
