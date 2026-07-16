import '../../domain/entities/security_status.dart';
import '../../domain/repositories/security_repository.dart';
import '../../domain/services/device_inspector.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  SecurityRepositoryImpl(this._inspector);
  final DeviceInspector _inspector;

  @override
  Future<SecurityStatus> check() => _inspector.inspect();
}
