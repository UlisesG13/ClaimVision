import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../features/cliente/presentation/state/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding_data.dart';
import 'providers.dart';

class OnboardingState {
  const OnboardingState({
    this.cedulaFrente,
    this.cedulaReverso,
    this.poliza,
    this.ocrLoading = false,
    this.submitting = false,
    this.completed = false,
    this.hasDetected = false,
    this.numeroPoliza = '',
    this.vigenciaPoliza = '',
    this.curpRfc = '',
    this.vehiculoMarca = '',
    this.vehiculoModelo = '',
    this.vehiculoAnio = '',
    this.vehiculoPlacas = '',
    this.aseguradora = '',
    this.nombreAsegurado = '',
    this.avisoPrivacidad = false,
    this.biometria = false,
    this.transferenciaTalleres = false,
    this.errorMessage,
  });

  final File? cedulaFrente;
  final File? cedulaReverso;
  final File? poliza;

  final bool ocrLoading;
  final bool submitting;
  final bool completed;
  final bool hasDetected;
  final String numeroPoliza;
  final String vigenciaPoliza;
  final String curpRfc;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final String vehiculoAnio;
  final String vehiculoPlacas;
  final String aseguradora;
  final String nombreAsegurado;

  final bool avisoPrivacidad;
  final bool biometria;
  final bool transferenciaTalleres;

  final String? errorMessage;

  bool get hasRequiredDocuments =>
      cedulaFrente != null && cedulaReverso != null && poliza != null;

  bool get canConfirm =>
      avisoPrivacidad &&
      numeroPoliza.trim().isNotEmpty &&
      vigenciaPoliza.trim().isNotEmpty &&
      curpRfc.trim().isNotEmpty &&
      !submitting;

  OnboardingState copyWith({
    File? cedulaFrente,
    File? cedulaReverso,
    File? poliza,
    bool? ocrLoading,
    bool? submitting,
    bool? completed,
    bool? hasDetected,
    String? numeroPoliza,
    String? vigenciaPoliza,
    String? curpRfc,
    String? vehiculoMarca,
    String? vehiculoModelo,
    String? vehiculoAnio,
    String? vehiculoPlacas,
    String? aseguradora,
    String? nombreAsegurado,
    bool? avisoPrivacidad,
    bool? biometria,
    bool? transferenciaTalleres,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      cedulaFrente: cedulaFrente ?? this.cedulaFrente,
      cedulaReverso: cedulaReverso ?? this.cedulaReverso,
      poliza: poliza ?? this.poliza,
      ocrLoading: ocrLoading ?? this.ocrLoading,
      submitting: submitting ?? this.submitting,
      completed: completed ?? this.completed,
      hasDetected: hasDetected ?? this.hasDetected,
      numeroPoliza: numeroPoliza ?? this.numeroPoliza,
      vigenciaPoliza: vigenciaPoliza ?? this.vigenciaPoliza,
      curpRfc: curpRfc ?? this.curpRfc,
      vehiculoMarca: vehiculoMarca ?? this.vehiculoMarca,
      vehiculoModelo: vehiculoModelo ?? this.vehiculoModelo,
      vehiculoAnio: vehiculoAnio ?? this.vehiculoAnio,
      vehiculoPlacas: vehiculoPlacas ?? this.vehiculoPlacas,
      aseguradora: aseguradora ?? this.aseguradora,
      nombreAsegurado: nombreAsegurado ?? this.nombreAsegurado,
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

  void setIdentificacionFrente(File file) =>
      state = state.copyWith(cedulaFrente: file, clearError: true);

  void setIdentificacionReverso(File file) =>
      state = state.copyWith(cedulaReverso: file, clearError: true);

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
  void editVehiculoMarca(String v) => state = state.copyWith(vehiculoMarca: v);
  void editVehiculoModelo(String v) => state = state.copyWith(vehiculoModelo: v);
  void editVehiculoAnio(String v) => state = state.copyWith(vehiculoAnio: v);
  void editVehiculoPlacas(String v) => state = state.copyWith(vehiculoPlacas: v);

  Future<void> runOcr() async {
    final frente = state.cedulaFrente;
    final poliza = state.poliza;
    if (frente == null || state.cedulaReverso == null || poliza == null) {
      state = state.copyWith(
        errorMessage: 'Agrega la INE (Frente y Reverso) y la póliza.',
      );
      return;
    }

    developer.log(
      '[OCR] Enviando: frente=${frente.path} (${frente.lengthSync()} bytes), poliza=${poliza.path} (${poliza.lengthSync()} bytes)',
    );

    state = state.copyWith(ocrLoading: true, clearError: true);
    try {
      final result = await ref.read(iaExtractAndValidateProvider)(
        poliza: poliza,
        ine: frente,
      );
      developer.log('[OCR] Resultado recibido: ${result.runtimeType}');
      final p = result.poliza;
      final i = result.ine;
      state = state.copyWith(
        ocrLoading: false,
        hasDetected: true,
        numeroPoliza: p.numeroPoliza,
        vigenciaPoliza: p.vigenciaFin,
        curpRfc: i.curp,
        vehiculoMarca: p.vehiculoMarca,
        vehiculoModelo: p.vehiculoModelo,
        vehiculoAnio: p.vehiculoAnio.toString(),
        vehiculoPlacas: p.vehiculoPlacas,
        aseguradora: p.aseguradora,
        nombreAsegurado: p.nombreAsegurado,
      );
    } on Failure catch (f) {
      developer.log('[OCR] Failure: ${f.message}');
      state = state.copyWith(ocrLoading: false, errorMessage: f.message);
    } catch (e) {
      developer.log('[OCR] Error inesperado: $e');
      state = state.copyWith(
        ocrLoading: false,
        errorMessage: 'No se pudieron analizar los documentos. Verifica que los PDFs sean legibles.',
      );
    }
  }

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
          vehiculoMarca: state.vehiculoMarca.trim(),
          vehiculoModelo: state.vehiculoModelo.trim(),
          vehiculoAnio: int.tryParse(state.vehiculoAnio.trim()) ?? 0,
          vehiculoPlacas: state.vehiculoPlacas.trim(),
        ),
      );
      final frente = state.cedulaFrente;
      final reverso = state.cedulaReverso;
      final poliza = state.poliza;
      if (frente != null && reverso != null && poliza != null) {
        try {
          developer.log(
            '[Upload] Subiendo: frente=${frente.path}, reverso=${reverso.path}, poliza=${poliza.path}',
          );
          await ref.read(documentoRepositoryProvider).subir(
                identificacion: frente,
                identificacionReverso: reverso,
                poliza: poliza,
              );
          developer.log('[Upload] Documentos subidos correctamente');
        } catch (e) {
          developer.log('[Upload] Falló la subida (best-effort): $e');
        }
      }
      state = state.copyWith(submitting: false, completed: true);
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);
