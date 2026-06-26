import 'dart:io';

import '../entities/onboarding_data.dart';
import '../repositories/onboarding_repository.dart';

/// Caso de uso: extraer los datos de la póliza por OCR a partir de las fotos
/// de la cédula y la póliza.
class ExtractPolicyData {
  const ExtractPolicyData(this._repository);

  final OnboardingRepository _repository;

  Future<OnboardingData> call({
    required File cedula,
    required File poliza,
  }) {
    return _repository.extractPolicyData(cedula: cedula, poliza: poliza);
  }
}
