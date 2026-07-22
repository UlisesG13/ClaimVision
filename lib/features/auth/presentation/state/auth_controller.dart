import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/sse_service.dart';
import '../../../../shared/state/sse_providers.dart';
import 'providers.dart';
import '../../domain/entities/auth_session.dart';

/// Controlador de la sesión de autenticación (flujo complejo → Riverpod).
///
/// Mantiene el `AsyncValue<AuthSession?>` global de la app:
///  - `loading`  → comprobando / autenticando.
///  - `data(null)`  → sin sesión (mostrar login).
///  - `data(session)` → autenticado.
///  - `error(Failure)` → fallo de login/registro (la UI muestra el mensaje).
///
/// Al construirse, restaura la sesión guardada en el dispositivo para que el
/// usuario no tenga que volver a iniciar sesión en cada arranque.
class AuthController extends AsyncNotifier<AuthSession?> {
  /// `false` solo durante la restauración inicial de la sesión al arrancar la
  /// app. El router usa esto para mostrar el splash una única vez y no volver a
  /// él durante un login/registro posterior.
  bool _bootstrapped = false;
  bool get isRestoring => !_bootstrapped;

  @override
  Future<AuthSession?> build() async {
    final session = await ref.read(getStoredSessionProvider)();
    _bootstrapped = true;
    if (session == null) return null;

    // El JWT no tiene refresh y expira (~60 min). Validamos el token guardado
    // contra el backend: si ya no es válido, arrancamos en el login.
    final valido = await ref.read(verifySessionProvider)();
    if (!valido) {
      await ref.read(logoutUserProvider)();
      return null;
    }
    return session;
  }

  /// Sesión actual si está autenticado, o `null`.
  AuthSession? get session => state.asData?.value;

  bool get isAuthenticated => session != null;

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final loginUser = ref.read(loginUserProvider);
      final session = await loginUser(email: email, password: password);
      _registerDeviceToken();
      _initSse(session);
      return session;
    });
  }

  Future<void> _registerDeviceToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final fcmToken = await messaging.getToken();
      if (fcmToken == null) return;

      final registerToken = ref.read(registerDeviceTokenProvider);
      await registerToken(fcmToken);

      messaging.onTokenRefresh.listen((newToken) async {
        final registerToken = ref.read(registerDeviceTokenProvider);
        await registerToken(newToken);
      });
    } catch (_) {}
  }

  Future<void> logout() async {
    _disposeSse();
    final logoutUser = ref.read(logoutUserProvider);
    await logoutUser();
    state = const AsyncData(null);
  }

  void _initSse(AuthSession session) {
    _disposeSse();
    final url = '${ApiConstants.baseUrl}${ApiConstants.eventsStream}';
    final service = SseService(url: url, token: session.token);
    ref.read(sseServiceProvider.notifier).setService(service);
  }

  void _disposeSse() {
    final existing = ref.read(sseServiceProvider);
    existing?.disconnect();
    ref.read(sseServiceProvider.notifier).setService(null);
  }

  /// Invocado por el interceptor de red cuando una llamada protegida devuelve
  /// 401 (token expirado/ inválido). El almacenamiento ya fue limpiado por el
  /// interceptor; aquí solo descartamos la sesión en memoria para que el router
  /// redirija al login.
  void handleUnauthorized() {
    if (state.asData?.value != null || state.isLoading) {
      _disposeSse();
      state = const AsyncData(null);
    }
  }
}

/// Provider global de la sesión. La UI y el router lo observan.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
