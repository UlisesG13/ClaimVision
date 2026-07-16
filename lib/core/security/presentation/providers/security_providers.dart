import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/providers.dart';
import '../../domain/entities/security_status.dart';

class SecurityController extends AsyncNotifier<SecurityStatus> {
  @override
  Future<SecurityStatus> build() async {
    final repo = ref.read(securityRepositoryProvider);
    return repo.check();
  }

  Future<void> recheck() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(securityRepositoryProvider);
      return repo.check();
    });
  }
}

final securityControllerProvider =
    AsyncNotifierProvider<SecurityController, SecurityStatus>(
  SecurityController.new,
);
