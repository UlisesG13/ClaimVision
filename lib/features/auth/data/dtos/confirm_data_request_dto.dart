/// Cuerpo de `POST /api/cliente/onboarding/confirmar-datos`
/// (`ConfirmDataRequestDTO`). Campos verbatim del backend.
class ConfirmDataRequestDto {
  const ConfirmDataRequestDto({
    required this.numeroPoliza,
    required this.vigenciaPoliza,
    required this.curpRfc,
  });

  final String numeroPoliza;
  final String vigenciaPoliza;
  final String curpRfc;

  Map<String, dynamic> toJson() => {
        'numero_poliza': numeroPoliza,
        'vigencia_poliza': vigenciaPoliza,
        'curp_rfc': curpRfc,
      };
}
