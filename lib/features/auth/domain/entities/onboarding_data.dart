/// Datos de la póliza extraídos por OCR y confirmados por el cliente en el
/// onboarding. Entidad pura (sin Flutter). Campos verbatim del backend.
class OnboardingData {
  const OnboardingData({
    required this.numeroPoliza,
    required this.vigenciaPoliza,
    required this.curpRfc,
    this.vehiculoMarca = '',
    this.vehiculoModelo = '',
    this.vehiculoAnio = 0,
    this.vehiculoPlacas = '',
  });

  final String numeroPoliza;

  /// Vigencia de la póliza en formato fecha (`YYYY-MM-DD`) tal como la maneja
  /// el backend.
  final String vigenciaPoliza;

  final String curpRfc;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final int vehiculoAnio;
  final String vehiculoPlacas;

  OnboardingData copyWith({
    String? numeroPoliza,
    String? vigenciaPoliza,
    String? curpRfc,
    String? vehiculoMarca,
    String? vehiculoModelo,
    int? vehiculoAnio,
    String? vehiculoPlacas,
  }) {
    return OnboardingData(
      numeroPoliza: numeroPoliza ?? this.numeroPoliza,
      vigenciaPoliza: vigenciaPoliza ?? this.vigenciaPoliza,
      curpRfc: curpRfc ?? this.curpRfc,
      vehiculoMarca: vehiculoMarca ?? this.vehiculoMarca,
      vehiculoModelo: vehiculoModelo ?? this.vehiculoModelo,
      vehiculoAnio: vehiculoAnio ?? this.vehiculoAnio,
      vehiculoPlacas: vehiculoPlacas ?? this.vehiculoPlacas,
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
