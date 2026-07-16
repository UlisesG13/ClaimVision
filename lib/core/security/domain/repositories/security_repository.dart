import '../entities/security_status.dart';

abstract class SecurityRepository {
  Future<SecurityStatus> check();
}
