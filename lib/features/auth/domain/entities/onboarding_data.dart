/// Datos de la póliza extraídos por OCR y confirmados por el cliente en el
/// onboarding. Entidad pura (sin Flutter). Campos verbatim del backend.
class OnboardingData {
  const OnboardingData({
    required this.numeroPoliza,
    required this.vigenciaPoliza,
    required this.curpRfc,
  });

  final String numeroPoliza;

  /// Vigencia de la póliza en formato fecha (`YYYY-MM-DD`) tal como la maneja
  /// el backend.
  final String vigenciaPoliza;

  final String curpRfc;

  OnboardingData copyWith({
    String? numeroPoliza,
    String? vigenciaPoliza,
    String? curpRfc,
  }) {
    return OnboardingData(
      numeroPoliza: numeroPoliza ?? this.numeroPoliza,
      vigenciaPoliza: vigenciaPoliza ?? this.vigenciaPoliza,
      curpRfc: curpRfc ?? this.curpRfc,
    );
  }
}

/// Consentimientos ARCO que el cliente otorga en el onboarding.
class ConsentData {
  const ConsentData({
    required this.avisoPrivacidad,
    required this.biometria,
    required this.transferenciaTalleres,
  });

  final bool avisoPrivacidad;
  final bool biometria;
  final bool transferenciaTalleres;
}
