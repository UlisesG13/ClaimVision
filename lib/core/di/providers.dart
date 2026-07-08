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
import '../../features/cliente/data/datasources/remote/cliente_remote_datasource.dart';
import '../../features/cliente/data/datasources/remote/siniestro_remote_datasource.dart';
import '../../features/cliente/data/repositories/cliente_repository_impl.dart';
import '../../features/cliente/data/repositories/siniestro_repository_impl.dart';
import '../../features/cliente/domain/repositories/cliente_repository.dart';
import '../../features/cliente/domain/repositories/siniestro_repository.dart';
import '../../features/cliente/domain/usecases/actualizar_siniestro.dart';
import '../../features/cliente/domain/usecases/get_perfil_cliente.dart';
import '../../features/cliente/domain/usecases/get_siniestro_detalle.dart';
import '../../features/cliente/domain/usecases/get_siniestros_cliente.dart';
import '../../features/cliente/domain/usecases/inicializar_siniestro.dart';
import '../../features/cliente/domain/usecases/subir_imagen_siniestro.dart';
import '../../features/ajustador/data/datasources/remote/peritaje_remote_datasource.dart';
import '../../features/ajustador/data/repositories/peritaje_repository_impl.dart';
import '../../features/ajustador/domain/repositories/peritaje_repository.dart';
import '../../features/ajustador/domain/usecases/confirmar_peritaje.dart';
import '../../features/ajustador/domain/usecases/get_casos_asignados.dart';
import '../../features/ajustador/domain/usecases/get_perfil_ajustador.dart';
import '../../features/ajustador/domain/usecases/guardar_peritaje.dart';
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

// ── Siniestros (cliente): datasource, repositorio y casos de uso ───────────
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

// ── Peritaje (ajustador): datasource, repositorio y casos de uso ───────────
final peritajeRemoteDataSourceProvider =
    Provider<PeritajeRemoteDataSource>((ref) {
  return PeritajeRemoteDataSourceImpl(ref.watch(dioProvider));
});

final peritajeRepositoryProvider = Provider<PeritajeRepository>((ref) {
  return PeritajeRepositoryImpl(ref.watch(peritajeRemoteDataSourceProvider));
});

final getCasosAsignadosProvider = Provider<GetCasosAsignados>((ref) {
  return GetCasosAsignados(ref.watch(peritajeRepositoryProvider));
});

final guardarPeritajeProvider = Provider<GuardarPeritaje>((ref) {
  return GuardarPeritaje(ref.watch(peritajeRepositoryProvider));
});

final confirmarPeritajeProvider = Provider<ConfirmarPeritaje>((ref) {
  return ConfirmarPeritaje(ref.watch(peritajeRepositoryProvider));
});

final getPerfilAjustadorProvider = Provider<GetPerfilAjustador>((ref) {
  return GetPerfilAjustador(ref.watch(peritajeRepositoryProvider));
});

// ── Cliente v1: perfil ─────────────────────────────────────────────────────
final clienteRemoteDataSourceProvider = Provider<ClienteRemoteDataSource>((ref) {
  return ClienteRemoteDataSourceImpl(ref.watch(dioProvider));
});

final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  return ClienteRepositoryImpl(ref.watch(clienteRemoteDataSourceProvider));
});

final getPerfilClienteProvider = Provider<GetPerfilCliente>((ref) {
  return GetPerfilCliente(ref.watch(clienteRepositoryProvider));
});

// ── Cliente v1: listar / detalle siniestros ────────────────────────────────
final getSiniestrosClienteProvider = Provider<GetSiniestrosCliente>((ref) {
  return GetSiniestrosCliente(ref.watch(siniestroRepositoryProvider));
});

final getSiniestroDetalleProvider = Provider<GetSiniestroDetalle>((ref) {
  return GetSiniestroDetalle(ref.watch(siniestroRepositoryProvider));
});
