import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../network/dio_client.dart';
import '../security/domain/repositories/security_repository.dart';
import '../security/data/repositories/security_repository_impl.dart';
import '../security/domain/services/device_inspector.dart';
import '../ia/data/datasources/ia_bridge_remote_datasource.dart';
import '../ia/data/ia_repository_impl.dart';
import '../ia/domain/ia_repository.dart';
import '../ia/domain/usecases/ia_check_health.dart';
import '../ia/domain/usecases/ia_history_uc.dart';
import '../ia/domain/usecases/ia_nlp_uc.dart';
import '../ia/domain/usecases/ia_ocr_uc.dart';
import '../ia/domain/usecases/ia_batch_uc.dart';
import '../ia/domain/usecases/ia_predict_uc.dart';
import '../services/biometric_service.dart';
import '../services/device_inspector_service.dart';
import '../services/image_picker_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/secure_storage_service.dart';

// ── Core: servicios ────────────────────────────────────────────────────────
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(
    ref.watch(secureStorageProvider),
    onUnauthorized: () {
      ref.read(authControllerProvider.notifier).handleUnauthorized();
    },
  );
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// ── Security ────────────────────────────────────────────────────────────────
final deviceInspectorProvider = Provider<DeviceInspector>((ref) {
  return DeviceInspectorService();
});

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  return SecurityRepositoryImpl(ref.watch(deviceInspectorProvider));
});

// ── Session ────────────────────────────────────────────────────────────────
final currentSessionProvider = Provider<AuthSession?>((ref) {
  return ref.watch(authControllerProvider).asData?.value;
});

// ── IA Bridge (Backend Proxy) ────────────────────────────────────────────
final iaBridgeRemoteDataSourceProvider = Provider<IaBridgeRemoteDataSource>((ref) {
  return IaBridgeRemoteDataSource(ref.watch(dioProvider));
});

final iaRepositoryProvider = Provider<IaRepository>((ref) {
  return IaRepositoryImpl(ref.watch(iaBridgeRemoteDataSourceProvider));
});

// ── IA: use cases ──────────────────────────────────────────────────────────
final iaPredictDamageV2Provider = Provider<IaPredictDamageV2>((ref) {
  return IaPredictDamageV2(ref.watch(iaRepositoryProvider));
});

final iaPredictAllDamageProvider = Provider<IaPredictAllDamage>((ref) {
  return IaPredictAllDamage(ref.watch(iaRepositoryProvider));
});

final iaObtenerResumenProvider = Provider<IaObtenerResumen>((ref) {
  return IaObtenerResumen(ref.watch(iaRepositoryProvider));
});

final iaExtractAndValidateProvider = Provider<IaExtractAndValidate>((ref) {
  return IaExtractAndValidate(ref.watch(iaRepositoryProvider));
});

final iaTranscribirAudioProvider = Provider<IaTranscribirAudio>((ref) {
  return IaTranscribirAudio(ref.watch(iaRepositoryProvider));
});

final iaTranscribirStatusProvider = Provider<IaTranscribirStatus>((ref) {
  return IaTranscribirStatus(ref.watch(iaRepositoryProvider));
});

final iaAnalizarTextoProvider = Provider<IaAnalizarTexto>((ref) {
  return IaAnalizarTexto(ref.watch(iaRepositoryProvider));
});

final iaCheckHealthProvider = Provider<IaCheckHealth>((ref) {
  return IaCheckHealth(ref.watch(iaRepositoryProvider));
});

final iaCheckHealthV2Provider = Provider<IaCheckHealthV2>((ref) {
  return IaCheckHealthV2(ref.watch(iaRepositoryProvider));
});

/// Estado de salud del IA Service: `(v1 disponible, v2 disponible)`.
final iaHealthStatusProvider = FutureProvider.autoDispose<({bool v1, bool v2})>((ref) async {
  var v1 = false;
  var v2 = false;
  try {
    final h = await ref.read(iaCheckHealthProvider)();
    v1 = h.modelLoaded;
  } catch (_) {}
  try {
    final h2 = await ref.read(iaCheckHealthV2Provider)();
    v2 = h2.modelLoaded;
  } catch (_) {}
  return (v1: v1, v2: v2);
});

// ── IA: historiales ────────────────────────────────────────────────────────
final iaGetV2HistoryProvider = Provider<IaGetV2History>((ref) {
  return IaGetV2History(ref.watch(iaRepositoryProvider));
});

final iaGetNlpHistoryProvider = Provider<IaGetNlpHistory>((ref) {
  return IaGetNlpHistory(ref.watch(iaRepositoryProvider));
});

final iaGetNlpDetailProvider = Provider<IaGetNlpDetail>((ref) {
  return IaGetNlpDetail(ref.watch(iaRepositoryProvider));
});

final iaV2HistoryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(iaGetV2HistoryProvider)();
});

final iaNlpHistoryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(iaGetNlpHistoryProvider)();
});
