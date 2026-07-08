class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://52.0.23.111:8000/api',
  );

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String register = '/v1/auth/register';
  static const String login = '/v1/auth/login';
  static const String me = '/v1/auth/me';
  static const String recoveryRequest = '/v1/auth/recovery/request';
  static const String recoveryVerify = '/v1/auth/recovery/verify';
  static const String recoveryReset = '/v1/auth/recovery/reset';
  static const String consentimiento = '/v1/auth/consentimiento';

  // ── Onboarding del cliente ────────────────────────────────────────────
  static const String onboardingOcr = '/cliente/onboarding/ocr';
  static const String onboardingConfirmar = '/cliente/onboarding/confirmar-datos';

  // ── Siniestros (cliente) ──────────────────────────────────────────────
  static const String siniestroInicializar = '/siniestros/inicializar';
  static String siniestro(String id) => '/siniestros/$id';
  static String siniestroImagenes(String id) => '/siniestros/$id/imagenes';

  // ── Cliente v1 ────────────────────────────────────────────────────────
  static const String clientePerfil = '/v1/cliente/perfil';
  static const String clienteSiniestros = '/v1/cliente/siniestros';
  static String clienteSiniestro(String id) => '/v1/cliente/siniestros/$id';

  // ── Ajustador v1 ─────────────────────────────────────────────────────
  static const String ajustadorPerfil = '/v1/ajustador/perfil';
  static const String ajustadorAsignaciones = '/v1/ajustador/asignaciones';
  static String ajustadorPeritaje(String id) => '/v1/ajustador/peritaje/$id';
  static String ajustadorConfirmar(String id) => '/v1/ajustador/peritaje/$id/confirmar';

  // Tiempos de espera de la red.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
