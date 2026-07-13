import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/providers.dart';
import '../../data/datasources/biometric_local_datasource.dart';
import '../../data/repositories/biometric_repository_impl.dart';
import '../../domain/repositories/biometric_repository.dart';

final biometricLocalDataSourceProvider = Provider<BiometricLocalDataSource>((ref) {
  return BiometricLocalDataSource(ref.watch(secureStorageProvider));
});

final biometricRepositoryProvider = Provider<BiometricRepository>((ref) {
  return BiometricRepositoryImpl(ref.watch(biometricLocalDataSourceProvider));
});
