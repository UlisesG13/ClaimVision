import 'package:flutter/services.dart';

import '../security/domain/entities/security_status.dart';
import '../security/domain/services/device_inspector.dart';

class DeviceInspectorService implements DeviceInspector {
  static const _channel = MethodChannel('com.claimvision/device_inspector');

  @override
  Future<SecurityStatus> inspect() async {
    try {
      final results = await _channel.invokeMethod<Map<Object?, Object?>>('inspect');
      if (results == null) return const SecurityOk();

      final issues = <SecurityIssue>[];
      if (results['isDeveloperOptionsEnabled'] == true) issues.add(SecurityIssue.developerOptions);
      if (results['isAdbEnabled'] == true) issues.add(SecurityIssue.adbEnabled);
      if (results['isAppDebuggable'] == true) issues.add(SecurityIssue.appDebuggable);
      if (results['isMockLocationActive'] == true) issues.add(SecurityIssue.mockLocation);
      if (results['isEmulator'] == true) issues.add(SecurityIssue.emulator);

      return issues.isEmpty
          ? const SecurityOk()
          : SecurityCompromised(issues);
    } on MissingPluginException {
      return const SecurityOk();
    }
  }
}
