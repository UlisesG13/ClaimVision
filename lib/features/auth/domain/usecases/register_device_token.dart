import '../repositories/auth_repository.dart';

class RegisterDeviceToken {
  RegisterDeviceToken(this._repository);

  final AuthRepository _repository;

  Future<void> call(String token) => _repository.registerDeviceToken(token);
}
