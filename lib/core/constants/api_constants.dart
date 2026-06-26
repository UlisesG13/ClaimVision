/// Configuración de red y endpoints del backend de ClaimVision.
///
/// La URL base se puede sobreescribir en tiempo de compilación con:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
///
/// Por defecto apunta a `10.0.2.2`, que en el emulador de Android resuelve al
/// `localhost` de la máquina anfitriona donde corre el backend (FastAPI en el
/// puerto 8000). En iOS Simulator usar `http://localhost:8000/api`.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://3.95.226.241:8000/api',
  );

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String recoveryRequest = '/auth/recovery/request';
  static const String recoveryVerify = '/auth/recovery/verify';
  static const String recoveryReset = '/auth/recovery/reset';
  static const String consentimiento = '/auth/consentimiento';

  // ── Onboarding del cliente ────────────────────────────────────────────
  static const String onboardingOcr = '/cliente/onboarding/ocr';
  static const String onboardingConfirmar = '/cliente/onboarding/confirmar-datos';

  // Tiempos de espera de la red.
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
