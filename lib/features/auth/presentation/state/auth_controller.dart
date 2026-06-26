import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  Future<AuthSession?> build() async {
    final getStored = ref.read(getStoredSessionProvider);
    return getStored();
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
    final logoutUser = ref.read(logoutUserProvider);
    await logoutUser();
    state = const AsyncData(null);
  }
}

/// Provider global de la sesión. La UI y el router lo observan.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
