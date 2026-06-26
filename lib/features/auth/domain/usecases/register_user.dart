import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: registrar un nuevo usuario (queda autenticado al terminar).
class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String nombre,
    required String email,
    required String password,
  }) {
    return _repository.register(
      nombre: nombre,
      email: email,
      password: password,
    );
  }
}
