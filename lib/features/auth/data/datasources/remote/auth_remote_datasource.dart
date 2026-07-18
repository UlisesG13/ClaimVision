import 'package:dio/dio.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/api_error_mapper.dart';
import '../../dtos/auth_response_dto.dart';
import '../../dtos/change_password_request_dto.dart';
import '../../dtos/device_token_request_dto.dart';
import '../../dtos/login_request_dto.dart';
import '../../dtos/register_request_dto.dart';

/// Llamadas REST de autenticación al backend (FastAPI).
/// Recibe el cliente [Dio] por inyección desde `core/di/`; no crea el suyo.
///
/// Lanza [AppException] tipadas (vía [ApiErrorMapper]) ante cualquier error;
/// el repositorio las traduce a `Failure`.
abstract interface class AuthRemoteDataSource {
  Future<AuthResponseDto> login(LoginRequestDto body);
  Future<AuthResponseDto> register(RegisterRequestDto body);

  /// Verifica el token actual contra `GET /auth/me`. Lanza
  /// [UnauthorizedException] si el token es inválido o expiró.
  Future<void> me();

  /// Cambia la contraseña del usuario autenticado.
  Future<void> changePassword(ChangePasswordRequestDto body);

  /// Registra el FCM token del dispositivo en el backend.
  Future<void> registerDeviceToken(DeviceTokenRequestDto body);

  /// Elimina el FCM token del dispositivo en el backend (logout).
  Future<void> deleteDeviceToken(DeviceTokenRequestDto body);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseDto> login(LoginRequestDto body) {
    return _post(ApiConstants.login, body.toJson());
  }

  @override
  Future<AuthResponseDto> register(RegisterRequestDto body) {
    return _post(ApiConstants.register, body.toJson());
  }

  @override
  Future<void> me() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      final status = response.statusCode ?? 500;
      if (status >= 400) {
        throw ApiErrorMapper.fromResponse(response);
      }
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequestDto body) async {
    try {
      final response = await _dio.patch(ApiConstants.cambiarPassword, data: body.toJson());
      final status = response.statusCode ?? 500;
      if (status >= 400) {
        throw ApiErrorMapper.fromResponse(response);
      }
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<void> registerDeviceToken(DeviceTokenRequestDto body) async {
    try {
      final response = await _dio.post(ApiConstants.deviceToken, data: body.toJson());
      final status = response.statusCode ?? 500;
      if (status >= 400) {
        throw ApiErrorMapper.fromResponse(response);
      }
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  @override
  Future<void> deleteDeviceToken(DeviceTokenRequestDto body) async {
    try {
      final response = await _dio.delete(ApiConstants.deviceToken, data: body.toJson());
      final status = response.statusCode ?? 500;
      if (status >= 400) {
        throw ApiErrorMapper.fromResponse(response);
      }
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  /// POST que devuelve un `LoginResponseDTO` (login y register comparten forma).
  Future<AuthResponseDto> _post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      final status = response.statusCode ?? 500;
      if (status >= 400) {
        // El validateStatus del Dio deja pasar < 500 sin lanzar.
        throw ApiErrorMapper.fromResponse(response);
      }
      return AuthResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }
}
