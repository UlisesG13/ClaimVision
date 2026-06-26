import '../repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión y limpiar los datos locales.
class LogoutUser {
  const LogoutUser(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
