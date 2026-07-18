// Los datasources se inyectan como interfaces y se asignan a campos privados;
// no aplican initializing formals porque los parámetros nombrados no pueden
// empezar con guion bajo en Dart.
// ignore_for_file: prefer_initializing_formals

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../dtos/change_password_request_dto.dart';
import '../dtos/device_token_request_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/register_request_dto.dart';
import '../mappers/auth_mapper.dart';

/// Implementación del contrato de autenticación.
///
/// Orquesta remoto + local: pide al backend, mapea DTO→Entity, persiste la
/// sesión de forma segura y traduce cualquier [AppException] técnica al
/// `Failure` que la UI entiende.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.login(
        LoginRequestDto(email: email, password: password),
      );
      final session = AuthMapper.toEntity(dto);
      await _local.cacheSession(session);
      return session;
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<AuthSession> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.register(
        RegisterRequestDto(nombre: nombre, email: email, password: password),
      );
      final session = AuthMapper.toEntity(dto);
      await _local.cacheSession(session);
      return session;
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    try {
      return await _local.readSession();
    } on AppException {
      return null;
    }
  }

  @override
  Future<bool> verifySession() async {
    try {
      await _remote.me();
      return true;
    } on UnauthorizedException {
      return false;
    } on ForbiddenException {
      return false;
    } on AppException {
      // Error de red u otro: no podemos confirmar que el token es inválido,
      // así que conservamos la sesión.
      return true;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await NotificationService.instance.getToken();
      if (token != null) {
        await _remote.deleteDeviceToken(DeviceTokenRequestDto(token: token));
      }
    } catch (_) {}
    await _local.clearSession();
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        ChangePasswordRequestDto(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      );
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<void> registerDeviceToken(String token) async {
    try {
      await _remote.registerDeviceToken(DeviceTokenRequestDto(token: token));
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  /// Traduce una excepción técnica de la capa data a un Failure de presentación.
  Failure _toFailure(AppException e) {
    return switch (e) {
      UnauthorizedException() => AuthFailure(e.message),
      ForbiddenException() => ForbiddenFailure(e.message),
      NotFoundException() => NotFoundFailure(e.message),
      ConflictException() => ConflictFailure(e.message),
      ValidationException() => ValidationFailure(e.message),
      CacheException() => CacheFailure(e.message),
      _ => ServerFailure(e.message),
    };
  }
}
