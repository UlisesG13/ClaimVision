import 'dart:io';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding_data.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/remote/onboarding_remote_datasource.dart';
import '../dtos/confirm_data_request_dto.dart';
import '../dtos/consent_request_dto.dart';

/// Implementación del onboarding: orquesta el datasource remoto y traduce las
/// excepciones técnicas a `Failure` para la UI.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._remote);

  final OnboardingRemoteDataSource _remote;

  @override
  Future<OnboardingData> extractPolicyData({
    required File cedula,
    required File poliza,
  }) async {
    try {
      final dto = await _remote.extractOcr(cedula: cedula, poliza: poliza);
      return OnboardingData(
        numeroPoliza: dto.numeroPoliza,
        vigenciaPoliza: dto.vigenciaPoliza,
        curpRfc: dto.curpRfc,
      );
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<void> sendConsent(ConsentData consent) async {
    try {
      await _remote.sendConsent(
        ConsentRequestDto(
          avisoPrivacidad: consent.avisoPrivacidad,
          biometria: consent.biometria,
          transferenciaTalleres: consent.transferenciaTalleres,
        ),
      );
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  @override
  Future<void> confirmOnboarding(OnboardingData data) async {
    try {
      await _remote.confirmData(
        ConfirmDataRequestDto(
          numeroPoliza: data.numeroPoliza,
          vigenciaPoliza: data.vigenciaPoliza,
          curpRfc: data.curpRfc,
        ),
      );
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(AppException e) {
    return switch (e) {
      UnauthorizedException() => AuthFailure(e.message),
      ForbiddenException() => ForbiddenFailure(e.message),
      NotFoundException() => NotFoundFailure(e.message),
      ConflictException() => ConflictFailure(e.message),
      ValidationException() => ValidationFailure(e.message),
      _ => ServerFailure(e.message),
    };
  }
}
