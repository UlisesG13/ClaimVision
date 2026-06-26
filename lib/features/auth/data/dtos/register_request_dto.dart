/// Cuerpo de `POST /api/auth/register`. Campos verbatim del backend
/// (`UserRegister` en el contrato): `nombre`, `email`, `password`.
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.nombre,
    required this.email,
    required this.password,
  });

  final String nombre;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'password': password,
      };
}
