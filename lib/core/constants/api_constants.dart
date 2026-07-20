class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.actividades.icu/api',
  );

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String register = '/v1/auth/register';
  static const String login = '/v1/auth/login';
  static const String me = '/v1/auth/me';
  static const String recoveryRequest = '/v1/auth/recovery/request';
  static const String recoveryVerify = '/v1/auth/recovery/verify';
  static const String recoveryReset = '/v1/auth/recovery/reset';
  static const String consentimiento = '/v1/auth/consentimiento';
  static const String cambiarPassword = '/v1/auth/password';
  static const String deviceToken = '/v1/auth/device-token';

  // ── Onboarding del cliente ────────────────────────────────────────────
  static const String onboardingOcr = '/v1/cliente/onboarding/ocr';
  static const String onboardingConfirmar = '/v1/cliente/onboarding/confirmar-datos';

  // ── Cliente v1 ────────────────────────────────────────────────────────
  static const String clientePerfil = '/v1/cliente/perfil';
  static const String clienteSiniestros = '/v1/cliente/siniestros';
  static String clienteSiniestro(String id) => '/v1/cliente/siniestros/$id';
  static String clienteSiniestroImagenes(String id) => '/v1/cliente/siniestros/$id/imagenes';
  static const String clienteVehiculos = '/v1/cliente/vehiculos';
  static const String clienteConsentimientos = '/v1/cliente/consentimientos';

  // ── Ajustador v1 ─────────────────────────────────────────────────────
  static const String ajustadorPerfil = '/v1/ajustador/perfil';
  static const String ajustadorAsignaciones = '/v1/ajustador/asignaciones';
  static String ajustadorSiniestro(String id) => '/v1/ajustador/siniestros/$id';
  static String ajustadorRegistrarPeritaje(String id) => '/v1/ajustador/siniestros/$id/peritaje';
  static String ajustadorEditarPeritaje(String id) => '/v1/ajustador/peritajes/$id';
  static String ajustadorPeritajeDanos(String id) => '/v1/ajustador/peritajes/$id/danos';

  // ── IA Bridge (Backend → IA Service) ──────────────────────────────────
  // Todos los endpoints IA se acceden vía backend proxy: /api/v1/ia/*

  // IA: OCR
  static const String iaBridgeOcr = '/v1/ia/ocr';
  static const String iaBridgeOcrExtractIne = '/v1/ia/ocr/extract-ine';
  static const String iaBridgeOcrExtractPoliza = '/v1/ia/ocr/extract-poliza';
  static const String iaBridgeOcrExtractAndValidate = '/v1/ia/ocr/extract-and-validate';
  static const String iaBridgeOcrHistory = '/v1/ia/ocr/history';

  // IA: Predict v1 (No Supervised)
  static const String iaBridgePredict = '/v1/ia/predict';
  static const String iaBridgeHistory = '/v1/ia/predict/history';
  static const String iaBridgeRetrain = '/v1/ia/predict/retrain';
  static const String iaBridgeHealth = '/v1/ia/predict/health';

  // IA: Predict v2 (Supervised / ResNet18)
  static const String iaBridgeV2Predict = '/v1/ia/v2/predict';
  static const String iaBridgeV2Retrain = '/v1/ia/v2/retrain';
  static String iaBridgeV2RetrainStatus(String jobId) => '/v1/ia/v2/retrain/$jobId/status';
  static const String iaBridgeV2History = '/v1/ia/v2/history';
  static const String iaBridgeV2Health = '/v1/ia/v2/health';

  // IA: NLP
  static const String iaBridgeNlpAnalizar = '/v1/ia/nlp/analizar';
  static const String iaBridgeNlpTranscribir = '/v1/ia/nlp/transcribir';
  static String iaBridgeNlpTranscribirStatus(String jobId) => '/v1/ia/nlp/transcribir/status/$jobId';
  static const String iaBridgeNlpHistory = '/v1/ia/nlp/history';
  static String iaBridgeNlpDetail(String id) => '/v1/ia/nlp/$id';

  // Tiempos de espera de la red.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
