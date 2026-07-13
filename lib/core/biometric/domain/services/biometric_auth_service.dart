abstract class BiometricAuthService {
  Future<bool> canCheckBiometrics();
  Future<bool> authenticate({String reason = 'Acceso biométrico'});
  Future<List<dynamic>> getAvailableBiometrics();
}
