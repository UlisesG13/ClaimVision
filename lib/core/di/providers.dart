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
import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/domain/usecases/send_consent.dart';
import '../../features/auth/domain/usecases/verify_session.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/incident/data/datasources/remote/siniestro_remote_datasource.dart';
import '../../features/incident/data/repositories/siniestro_repository_impl.dart';
import '../../features/incident/domain/repositories/siniestro_repository.dart';
import '../../features/incident/domain/usecases/actualizar_siniestro.dart';
import '../../features/incident/domain/usecases/inicializar_siniestro.dart';
import '../../features/incident/domain/usecases/subir_imagen_siniestro.dart';
import '../network/dio_client.dart';
import '../services/image_picker_service.dart';
import '../services/location_service.dart';
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
  return DioClient.create(
    ref.watch(secureStorageProvider),
    // Un 401 en una llamada protegida invalida la sesión en memoria; el router
    // detecta que ya no hay sesión y manda al login.
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

final verifySessionProvider = Provider<VerifySession>((ref) {
  return VerifySession(ref.watch(authRepositoryProvider));
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

/// Sesión autenticada actual, expuesta desde el composition root para que
/// cualquier feature la lea sin depender directamente del feature `auth`.
final currentSessionProvider = Provider<AuthSession?>((ref) {
  return ref.watch(authControllerProvider).asData?.value;
});

// ── Siniestros (incident): datasource, repositorio y casos de uso ──────────
final siniestroRemoteDataSourceProvider =
    Provider<SiniestroRemoteDataSource>((ref) {
  return SiniestroRemoteDataSourceImpl(ref.watch(dioProvider));
});

final siniestroRepositoryProvider = Provider<SiniestroRepository>((ref) {
  return SiniestroRepositoryImpl(ref.watch(siniestroRemoteDataSourceProvider));
});

final inicializarSiniestroProvider = Provider<InicializarSiniestro>((ref) {
  return InicializarSiniestro(ref.watch(siniestroRepositoryProvider));
});

final actualizarSiniestroProvider = Provider<ActualizarSiniestro>((ref) {
  return ActualizarSiniestro(ref.watch(siniestroRepositoryProvider));
});

final subirImagenSiniestroProvider = Provider<SubirImagenSiniestro>((ref) {
  return SubirImagenSiniestro(ref.watch(siniestroRepositoryProvider));
});
