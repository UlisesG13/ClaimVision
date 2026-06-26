/// Fallos que la capa de presentación SÍ entiende.
///
/// La UI nunca recibe una `DioException` cruda: el repositorio captura las
/// excepciones técnicas y las convierte en uno de estos `Failure`, que llevan
/// un `message` listo para mostrar al usuario en español.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Problema de red o del servidor (sin conexión, timeout, 5xx).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un problema con el servidor. Inténtalo de nuevo.']);
}

/// Credenciales incorrectas o sesión expirada (401).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Correo o contraseña incorrectos.']);
}

/// Acceso denegado: cuenta bloqueada por ARCO o sin permisos (403).
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'No tienes acceso a este recurso.']);
}

/// El recurso solicitado no existe (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No se encontró la información solicitada.']);
}

/// Conflicto: el correo ya está registrado, conflicto de estado (409).
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Ya existe un registro con estos datos.']);
}

/// Datos inválidos enviados al backend (400 / 422).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Revisa los datos ingresados.']);
}

/// No hay sesión guardada en el dispositivo.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No hay una sesión activa.']);
}
