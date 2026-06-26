/// Respuesta de `POST /api/cliente/onboarding/ocr`. Campos verbatim.
class OcrResponseDto {
  const OcrResponseDto({
    required this.numeroPoliza,
    required this.vigenciaPoliza,
    required this.curpRfc,
  });

  final String numeroPoliza;
  final String vigenciaPoliza;
  final String curpRfc;

  factory OcrResponseDto.fromJson(Map<String, dynamic> json) {
    return OcrResponseDto(
      numeroPoliza: (json['numero_poliza'] ?? '').toString(),
      vigenciaPoliza: (json['vigencia_poliza'] ?? '').toString(),
      curpRfc: (json['curp_rfc'] ?? '').toString(),
    );
  }
}
