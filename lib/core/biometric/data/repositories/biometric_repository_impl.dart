import '../../domain/entities/biometric_credentials.dart';
import '../../domain/repositories/biometric_repository.dart';
import '../datasources/biometric_local_datasource.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDataSource _dataSource;

  BiometricRepositoryImpl(this._dataSource);

  @override
  Future<bool> isEnabled() => _dataSource.isEnabled();

  @override
  Future<void> enable({
    required String userId,
    required String email,
    required String password,
  }) async {
    await _dataSource.save(email: email, password: password);
  }

  @override
  Future<void> disable() => _dataSource.disable();

  @override
  Future<BiometricCredentials?> getCredentials() async {
    final enabled = await _dataSource.isEnabled();
    if (!enabled) return null;
    final email = await _dataSource.getEmail();
    final password = await _dataSource.getDecryptedPassword();
    if (email == null || password == null) return null;
    return BiometricCredentials(email: email, password: password);
  }

  @override
  Future<void> clearForUser(String userId) => _dataSource.deleteAll();
}
