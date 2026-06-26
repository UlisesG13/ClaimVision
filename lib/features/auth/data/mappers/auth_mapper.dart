import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_role.dart';
import '../dtos/auth_response_dto.dart';

/// Convierte el DTO de respuesta del backend en la entidad de dominio.
/// Función pura: no toca red ni almacenamiento.
class AuthMapper {
  AuthMapper._();

  static AuthSession toEntity(AuthResponseDto dto) {
    return AuthSession(
      token: dto.token,
      usuarioId: dto.usuarioId,
      email: dto.email,
      rol: UserRole.fromApi(dto.rol),
      aseguradoraId: dto.aseguradoraId,
    );
  }
}
