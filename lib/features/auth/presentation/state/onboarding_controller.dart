import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding_data.dart';

/// Estado del onboarding (vincular póliza). Flujo multi-paso con red → Riverpod.
class OnboardingState {
  const OnboardingState({
    this.cedula,
    this.poliza,
    this.ocrLoading = false,
    this.submitting = false,
    this.completed = false,
    this.hasDetected = false,
    this.numeroPoliza = '',
    this.vigenciaPoliza = '',
    this.curpRfc = '',
    this.avisoPrivacidad = false,
    this.biometria = false,
    this.transferenciaTalleres = false,
    this.errorMessage,
  });

  final File? cedula;
  final File? poliza;
  final bool ocrLoading;
  final bool submitting;
  final bool completed;

  /// Si ya se ejecutó el OCR y se llenaron los campos detectados.
  final bool hasDetected;
  final String numeroPoliza;
  final String vigenciaPoliza;
  final String curpRfc;

  // Consentimientos ARCO.
  final bool avisoPrivacidad;
  final bool biometria;
  final bool transferenciaTalleres;

  final String? errorMessage;

  bool get hasBothImages => cedula != null && poliza != null;

  /// El botón "Confirmar y Vincular" se habilita cuando hay datos y el aviso de
  /// privacidad está aceptado (gate obligatorio del dominio).
  bool get canConfirm =>
      avisoPrivacidad &&
      numeroPoliza.trim().isNotEmpty &&
      vigenciaPoliza.trim().isNotEmpty &&
      curpRfc.trim().isNotEmpty &&
      !submitting;

  OnboardingState copyWith({
    File? cedula,
    File? poliza,
    bool? ocrLoading,
    bool? submitting,
    bool? completed,
    bool? hasDetected,
    String? numeroPoliza,
    String? vigenciaPoliza,
    String? curpRfc,
    bool? avisoPrivacidad,
    bool? biometria,
    bool? transferenciaTalleres,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      cedula: cedula ?? this.cedula,
      poliza: poliza ?? this.poliza,
      ocrLoading: ocrLoading ?? this.ocrLoading,
      submitting: submitting ?? this.submitting,
      completed: completed ?? this.completed,
      hasDetected: hasDetected ?? this.hasDetected,
      numeroPoliza: numeroPoliza ?? this.numeroPoliza,
      vigenciaPoliza: vigenciaPoliza ?? this.vigenciaPoliza,
      curpRfc: curpRfc ?? this.curpRfc,
      avisoPrivacidad: avisoPrivacidad ?? this.avisoPrivacidad,
      biometria: biometria ?? this.biometria,
      transferenciaTalleres:
          transferenciaTalleres ?? this.transferenciaTalleres,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setCedula(File file) =>
      state = state.copyWith(cedula: file, clearError: true);

  void setPoliza(File file) =>
      state = state.copyWith(poliza: file, clearError: true);

  void toggleAviso(bool value) =>
      state = state.copyWith(avisoPrivacidad: value);

  void toggleBiometria(bool value) =>
      state = state.copyWith(biometria: value);

  void toggleTransferencia(bool value) =>
      state = state.copyWith(transferenciaTalleres: value);

  void editNumeroPoliza(String v) => state = state.copyWith(numeroPoliza: v);
  void editVigencia(String v) => state = state.copyWith(vigenciaPoliza: v);
  void editCurpRfc(String v) => state = state.copyWith(curpRfc: v);

  /// Ejecuta el OCR sobre cédula + póliza y llena los campos detectados.
  Future<void> runOcr() async {
    final cedula = state.cedula;
    final poliza = state.poliza;
    if (cedula == null || poliza == null) {
      state = state.copyWith(
        errorMessage: 'Agrega la foto de tu cédula y de tu póliza.',
      );
      return;
    }

    state = state.copyWith(ocrLoading: true, clearError: true);
    try {
      final data = await ref.read(extractPolicyDataProvider)(
        cedula: cedula,
        poliza: poliza,
      );
      state = state.copyWith(
        ocrLoading: false,
        hasDetected: true,
        numeroPoliza: data.numeroPoliza,
        vigenciaPoliza: data.vigenciaPoliza,
        curpRfc: data.curpRfc,
      );
    } on Failure catch (f) {
      state = state.copyWith(ocrLoading: false, errorMessage: f.message);
    }
  }

  /// Envía consentimientos y confirma los datos. Marca `completed` al terminar.
  Future<void> confirm() async {
    if (!state.canConfirm) return;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref.read(sendConsentProvider)(
        ConsentData(
          avisoPrivacidad: state.avisoPrivacidad,
          biometria: state.biometria,
          transferenciaTalleres: state.transferenciaTalleres,
        ),
      );
      await ref.read(confirmOnboardingProvider)(
        OnboardingData(
          numeroPoliza: state.numeroPoliza.trim(),
          vigenciaPoliza: state.vigenciaPoliza.trim(),
          curpRfc: state.curpRfc.trim(),
        ),
      );
      state = state.copyWith(submitting: false, completed: true);
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);
