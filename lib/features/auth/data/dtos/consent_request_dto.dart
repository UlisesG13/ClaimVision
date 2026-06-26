/// Cuerpo de `POST /api/auth/consentimiento` (`ConsentRequestDTO`).
/// Campos verbatim del backend.
class ConsentRequestDto {
  const ConsentRequestDto({
    required this.avisoPrivacidad,
    required this.biometria,
    required this.transferenciaTalleres,
  });

  final bool avisoPrivacidad;
  final bool biometria;
  final bool transferenciaTalleres;

  Map<String, dynamic> toJson() => {
        'aviso_privacidad': avisoPrivacidad,
        'biometria': biometria,
        'transferencia_talleres': transferenciaTalleres,
      };
}
