import '../entities/onboarding_data.dart';
import '../repositories/onboarding_repository.dart';

/// Caso de uso: registrar los consentimientos ARCO del cliente.
class SendConsent {
  const SendConsent(this._repository);

  final OnboardingRepository _repository;

  Future<void> call(ConsentData consent) => _repository.sendConsent(consent);
}
