import '../entities/biometric_credentials.dart';

abstract class BiometricRepository {
  Future<bool> isEnabled();
  Future<void> enable({required String userId, required String email, required String password});
  Future<void> disable();
  Future<BiometricCredentials?> getCredentials();
  Future<void> clearForUser(String userId);
}
