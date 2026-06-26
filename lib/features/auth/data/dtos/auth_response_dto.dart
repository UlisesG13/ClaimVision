/// Respuesta de `POST /api/auth/login` y `POST /api/auth/register`
/// (`LoginResponseDTO` en el contrato). Campos verbatim del backend.
class AuthResponseDto {
  const AuthResponseDto({
    required this.token,
    required this.usuarioId,
    required this.email,
    required this.rol,
    this.aseguradoraId,
  });

  final String token;
  final String usuarioId;
  final String email;
  final String rol;
  final String? aseguradoraId;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String,
      usuarioId: json['usuario_id'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      aseguradoraId: json['aseguradora_id'] as String?,
    );
  }
}
