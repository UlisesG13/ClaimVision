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

  // ── IA Service ─────────────────────────────────────────────────────────
  static const String iaBaseUrl = String.fromEnvironment(
    'IA_BASE_URL',
    defaultValue: 'https://ia.actividades.icu',
  );

  // ── IA: OCR ────────────────────────────────────────────────────────────
  static const String iaOcr = '/api/v1/ocr';
  static const String iaOcrExtractIne = '/api/v1/ocr/extract-ine';
  static const String iaOcrExtractPoliza = '/api/v1/ocr/extract-poliza';
  static const String iaOcrExtractAndValidate = '/api/v1/ocr/extract-and-validate';
  static const String iaOcrHistory = '/api/v1/ocr/history';

  // ── IA: Predict (No Supervised v1) ─────────────────────────────────────
  static const String iaPredict = '/api/v1/predict';
  static const String iaHistory = '/api/v1/history';
  static const String iaRetrain = '/api/v1/retrain';
  static const String iaHealth = '/api/v1/health';

  // ── IA: Supervised v2 ──────────────────────────────────────────────────
  static const String iaV2Predict = '/api/v2/predict';
  static const String iaV2Retrain = '/api/v2/retrain';
  static String iaV2RetrainStatus(String jobId) => '/api/v2/retrain/$jobId';
  static const String iaV2History = '/api/v2/history';
  static const String iaV2Health = '/api/v2/health';

  // ── IA: NLP ────────────────────────────────────────────────────────────
  static const String iaNlpAnalizar = '/api/v1/nlp/analizar';
  static const String iaNlpTranscribir = '/api/v1/nlp/transcribir';
  static String iaNlpTranscribirStatus(String jobId) => '/api/v1/nlp/transcribir/status/$jobId';
  static const String iaNlpHistory = '/api/v1/nlp/history';
  static String iaNlpDetail(String id) => '/api/v1/nlp/$id';

  // Tiempos de espera de la red.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
