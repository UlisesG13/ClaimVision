import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

/// Traduce errores HTTP/red del backend a [AppException] tipadas.
///
/// El backend devuelve los errores con el formato `{ "detail": ... }`, donde
/// `detail` puede ser un string o una lista de errores de validación de
/// Pydantic. Aquí extraemos un mensaje legible en español.
class ApiErrorMapper {
  ApiErrorMapper._();

  /// Convierte una respuesta con código de error (>= 400) en excepción.
  static AppException fromResponse(Response response) {
    final status = response.statusCode ?? 500;
    final message = _extractDetail(response.data, status);
    return _byStatus(status, message);
  }

  /// Convierte una [DioException] (timeout, sin conexión, etc.) en excepción.
  static AppException fromDioException(DioException e) {
    // Si hay respuesta del servidor, mapear por código.
    final response = e.response;
    if (response != null) {
      return fromResponse(response);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(
          'La conexión tardó demasiado. Revisa tu red e inténtalo de nuevo.',
        );
      case DioExceptionType.connectionError:
        return const ServerException(
          'No se pudo conectar con el servidor. Verifica tu conexión.',
        );
      default:
        return const ServerException(
          'Ocurrió un problema inesperado. Inténtalo de nuevo.',
        );
    }
  }

  static AppException _byStatus(int status, String message) {
    return switch (status) {
      400 || 422 => ValidationException(message, statusCode: status),
      401 => UnauthorizedException(message),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      409 => ConflictException(message),
      _ => ServerException(message, statusCode: status),
    };
  }

  /// Extrae el mensaje del campo `detail` del cuerpo del error.
  static String _extractDetail(dynamic data, int status) {
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      // Errores de validación de Pydantic: lista de {loc, msg, type}.
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
      }
    }
    return _defaultMessage(status);
  }

  static String _defaultMessage(int status) {
    return switch (status) {
      400 || 422 => 'Revisa los datos ingresados.',
      401 => 'Correo o contraseña incorrectos.',
      403 => 'No tienes acceso a este recurso.',
      404 => 'No se encontró la información solicitada.',
      409 => 'Ya existe un registro con estos datos.',
      _ => 'Ocurrió un problema con el servidor. Inténtalo de nuevo.',
    };
  }
}
