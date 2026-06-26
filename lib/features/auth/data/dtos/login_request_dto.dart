/// Cuerpo de `POST /api/auth/login`. Campos verbatim del backend
/// (`LoginRequestDTO` en el contrato).
class LoginRequestDto {
  const LoginRequestDto({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
