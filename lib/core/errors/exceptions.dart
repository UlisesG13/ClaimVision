/// Excepciones técnicas que se lanzan dentro de la capa `data`.
///
/// Estas excepciones NUNCA deben salir hacia la capa de presentación: la
/// implementación del repositorio las captura y las traduce a `Failure`
/// (ver `core/errors/failures.dart`).
library;

/// Excepción base de la app. Lleva un mensaje ya legible para el usuario
/// (extraído del campo `detail` del backend cuando existe).
class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppException($statusCode): $message';
}

/// Error de red / servidor (5xx, timeouts, sin conexión).
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Credenciales inválidas o token expirado (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode = 401});
}

/// Usuario bloqueado por ARCO o sin permisos (403).
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.statusCode = 403});
}

/// Recurso no encontrado (404).
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode = 404});
}

/// Conflicto: registro duplicado, conflicto de estado (409).
class ConflictException extends AppException {
  const ConflictException(super.message, {super.statusCode = 409});
}

/// Error de validación de Pydantic (422) o datos inválidos (400).
class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode = 422});
}

/// No hay sesión almacenada localmente.
class CacheException extends AppException {
  const CacheException(super.message);
}
