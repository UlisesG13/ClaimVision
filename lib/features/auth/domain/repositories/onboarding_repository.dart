import 'dart:io';

import '../entities/onboarding_data.dart';

/// Contrato del onboarding del cliente (vincular póliza).
/// Lanza `Failure` ante error; devuelve la entidad en caso de éxito.
abstract interface class OnboardingRepository {
  /// Sube cédula y póliza y devuelve los datos extraídos por OCR.
  Future<OnboardingData> extractPolicyData({
    required File cedula,
    required File poliza,
  });

  /// Registra los consentimientos ARCO del usuario autenticado.
  Future<void> sendConsent(ConsentData consent);

  /// Confirma y guarda de forma cifrada los datos de la póliza.
  Future<void> confirmOnboarding(OnboardingData data);
}
