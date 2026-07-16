import '../entities/security_status.dart';

abstract class DeviceInspector {
  Future<SecurityStatus> inspect();
}
