import '../repositories/auth_repository.dart';

/// Caso de uso: validar contra el backend si el token guardado sigue vigente.
class VerifySession {
  const VerifySession(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.verifySession();
}
