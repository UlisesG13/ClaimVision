class PerfilCliente {
  const PerfilCliente({
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
}
