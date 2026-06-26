import '../entities/onboarding_data.dart';
import '../repositories/onboarding_repository.dart';

/// Caso de uso: confirmar y guardar los datos de la póliza del onboarding.
class ConfirmOnboarding {
  const ConfirmOnboarding(this._repository);

  final OnboardingRepository _repository;

  Future<void> call(OnboardingData data) =>
      _repository.confirmOnboarding(data);
}
