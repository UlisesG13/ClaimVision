import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/onboarding_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/confirm_onboarding.dart';
import '../../domain/usecases/extract_policy_data.dart';
import '../../domain/usecases/get_stored_session.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_device_token.dart';
import '../../domain/usecases/send_consent.dart';
import '../../domain/usecases/verify_session.dart';

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

final getStoredSessionProvider = Provider<GetStoredSession>((ref) {
  return GetStoredSession(ref.watch(authRepositoryProvider));
});

final verifySessionProvider = Provider<VerifySession>((ref) {
  return VerifySession(ref.watch(authRepositoryProvider));
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.watch(authRepositoryProvider));
});

final registerDeviceTokenProvider = Provider<RegisterDeviceToken>((ref) {
  return RegisterDeviceToken(ref.watch(authRepositoryProvider));
});

final changePasswordProvider = Provider<ChangePassword>((ref) {
  return ChangePassword(ref.watch(authRepositoryProvider));
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
