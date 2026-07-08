class ClienteResponseDto {
  const ClienteResponseDto({
    required this.id,
    required this.usuarioId,
    required this.numeroPoliza,
    required this.vigenciaPoliza,
    required this.consentimientoAvisoPrivacidad,
    required this.consentimientoBiometria,
    required this.autorizaTransferenciaTalleres,
    this.fechaConsentimiento,
  });

  final String id;
  final String usuarioId;
  final String numeroPoliza;
  final String vigenciaPoliza;
  final bool consentimientoAvisoPrivacidad;
  final bool consentimientoBiometria;
  final bool autorizaTransferenciaTalleres;
  final DateTime? fechaConsentimiento;

  factory ClienteResponseDto.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic v) =>
        v != null ? DateTime.tryParse('$v')?.toLocal() : null;

    return ClienteResponseDto(
      id: (json['id'] ?? '').toString(),
      usuarioId: (json['usuario_id'] ?? '').toString(),
      numeroPoliza: (json['numero_poliza'] ?? '').toString(),
      vigenciaPoliza: (json['vigencia_poliza'] ?? '').toString(),
      consentimientoAvisoPrivacidad:
          json['consentimiento_aviso_privacidad'] == true,
      consentimientoBiometria: json['consentimiento_biometria'] == true,
      autorizaTransferenciaTalleres:
          json['autoriza_transferencia_talleres'] == true,
      fechaConsentimiento: toDate(json['fecha_consentimiento']),
    );
  }
}
