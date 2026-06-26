import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: obtener la sesión persistida al arrancar la app.
class GetStoredSession {
  const GetStoredSession(this._repository);

  final AuthRepository _repository;

  Future<AuthSession?> call() => _repository.getStoredSession();
}
