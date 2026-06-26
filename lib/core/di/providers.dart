import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/local/auth_local_datasource.dart';
import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/remote/onboarding_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/onboarding_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/onboarding_repository.dart';
import '../../features/auth/domain/usecases/confirm_onboarding.dart';
import '../../features/auth/domain/usecases/extract_policy_data.dart';
import '../../features/auth/domain/usecases/get_stored_session.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';
import '../../features/auth/domain/usecases/send_consent.dart';
import '../network/dio_client.dart';
import '../services/image_picker_service.dart';
import '../services/secure_storage_service.dart';

/// Contenedor de inyección de dependencias de la app (Riverpod).
///
/// Aquí se registran, de abajo hacia arriba, las dependencias de
/// infraestructura, datasources, repositorios y casos de uso. Las pantallas y
/// notifiers consumen los casos de uso, nunca instancian datasources a mano.

// ── Infraestructura ──────────────────────────────────────────────────────
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(const FlutterSecureStorage());
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(ref.watch(secureStorageProvider));
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

// ── Auth: datasources ──────────────────────────────────────────────────────
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(secureStorageProvider));
});

// ── Auth: repositorio ──────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});

// ── Auth: casos de uso ─────────────────────────────────────────────────────
final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});

final getStoredSessionProvider = Provider<GetStoredSession>((ref) {
  return GetStoredSession(ref.watch(authRepositoryProvider));
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.watch(authRepositoryProvider));
});

// ── Onboarding (cliente): datasource, repositorio y casos de uso ───────────
final onboardingRemoteDataSourceProvider =
    Provider<OnboardingRemoteDataSource>((ref) {
  return OnboardingRemoteDataSourceImpl(ref.watch(dioProvider));
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingRemoteDataSourceProvider));
});

final extractPolicyDataProvider = Provider<ExtractPolicyData>((ref) {
  return ExtractPolicyData(ref.watch(onboardingRepositoryProvider));
});

final sendConsentProvider = Provider<SendConsent>((ref) {
  return SendConsent(ref.watch(onboardingRepositoryProvider));
});

final confirmOnboardingProvider = Provider<ConfirmOnboarding>((ref) {
  return ConfirmOnboarding(ref.watch(onboardingRepositoryProvider));
});
