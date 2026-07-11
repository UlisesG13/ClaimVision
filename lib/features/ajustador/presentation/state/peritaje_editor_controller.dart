import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dano_ajustado.dart';

class PeritajeEditorState {
  const PeritajeEditorState({
    this.siniestroId = '',
    this.danos = const [],
    this.observaciones = '',
    this.costoOverride,
    this.firmaBase64,
    this.submitting = false,
    this.errorMessage,
    this.resultado,
  });

  final String siniestroId;
  final List<DanoAjustado> danos;
  final String observaciones;
  final double? costoOverride;
  final String? firmaBase64;
  final bool submitting;
  final String? errorMessage;
  final Siniestro? resultado;

  double get costoSugerido =>
      danos.fold(0, (sum, d) => sum + d.costoRealReparacion);
  double get costoDefinitivo => costoOverride ?? costoSugerido;

  bool get tieneDanos => danos.isNotEmpty;
  bool get tieneFirma => (firmaBase64 ?? '').isNotEmpty;
  bool get puedeConfirmar => tieneDanos && tieneFirma && !submitting;

  PeritajeEditorState copyWith({
    String? siniestroId,
    List<DanoAjustado>? danos,
    String? observaciones,
    double? costoOverride,
    bool clearCostoOverride = false,
    String? firmaBase64,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
    Siniestro? resultado,
  }) {
    return PeritajeEditorState(
      siniestroId: siniestroId ?? this.siniestroId,
      danos: danos ?? this.danos,
      observaciones: observaciones ?? this.observaciones,
      costoOverride:
          clearCostoOverride ? null : (costoOverride ?? this.costoOverride),
      firmaBase64: firmaBase64 ?? this.firmaBase64,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      resultado: resultado ?? this.resultado,
    );
  }
}

class PeritajeEditorController extends Notifier<PeritajeEditorState> {
  @override
  PeritajeEditorState build() => const PeritajeEditorState();

  void iniciar(String siniestroId) {
    state = PeritajeEditorState(siniestroId: siniestroId);
  }

  void agregarDano(DanoAjustado dano) =>
      state = state.copyWith(danos: [...state.danos, dano], clearError: true);

  void actualizarDano(int index, DanoAjustado dano) {
    final lista = [...state.danos];
    if (index < 0 || index >= lista.length) return;
    lista[index] = dano;
    state = state.copyWith(danos: lista);
  }

  void quitarDano(int index) {
    final lista = [...state.danos]..removeAt(index);
    state = state.copyWith(danos: lista);
  }

  void setObservaciones(String v) => state = state.copyWith(observaciones: v);

  void setCostoDefinitivo(double? v) => v == null
      ? state = state.copyWith(clearCostoOverride: true)
      : state = state.copyWith(costoOverride: v);

  void setFirma(String base64) =>
      state = state.copyWith(firmaBase64: base64, clearError: true);

  Future<bool> registrarYConfirmar() async {
    if (!state.puedeConfirmar) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref.read(registrarPeritajeProvider)(
        siniestroId: state.siniestroId,
        costoDefinitivo: state.costoDefinitivo,
        firmaDigitalBase64: state.firmaBase64!,
        danos: state.danos,
        observacionesCampo:
            state.observaciones.trim().isEmpty ? null : state.observaciones.trim(),
      );
      state = state.copyWith(submitting: false);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
      return false;
    }
  }
}

final peritajeEditorControllerProvider =
    NotifierProvider<PeritajeEditorController, PeritajeEditorState>(
        PeritajeEditorController.new);
