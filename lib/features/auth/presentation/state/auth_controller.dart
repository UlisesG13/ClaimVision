import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/biometric/presentation/providers/biometric_providers.dart';
import '../../../../core/di/providers.dart';
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
      return loginUser(email: email, password: password);
    });
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final registerUser = ref.read(registerUserProvider);
      return registerUser(nombre: nombre, email: email, password: password);
    });
  }

  Future<void> logout() async {
    final userId = session?.usuarioId;
    final logoutUser = ref.read(logoutUserProvider);
    await logoutUser();
    if (userId != null) {
      await ref.read(biometricRepositoryProvider).clearForUser(userId);
    }
    state = const AsyncData(null);
  }

  /// Invocado por el interceptor de red cuando una llamada protegida devuelve
  /// 401 (token expirado/ inválido). El almacenamiento ya fue limpiado por el
  /// interceptor; aquí solo descartamos la sesión en memoria para que el router
  /// redirija al login.
  void handleUnauthorized() {
    if (state.asData?.value != null || state.isLoading) {
      state = const AsyncData(null);
    }
  }
}

/// Provider global de la sesión. La UI y el router lo observan.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
