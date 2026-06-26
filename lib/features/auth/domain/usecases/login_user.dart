import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión con correo y contraseña.
class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
