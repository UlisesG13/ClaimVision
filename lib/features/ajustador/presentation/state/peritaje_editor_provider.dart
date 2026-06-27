import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dano_ajustado.dart';

/// Borrador del peritaje que el ajustador arma a lo largo de Validación → Firma.
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

  /// Costo definitivo si el ajustador lo sobreescribe; si es `null` se usa la
  /// suma de los daños.
  final double? costoOverride;

  /// Firma del ajustador en base64 (PNG), capturada en la pantalla de firma.
  final String? firmaBase64;

  final bool submitting;
  final String? errorMessage;

  /// Siniestro resultante tras confirmar (estatus `Peritaje_Validado`).
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

  /// Inicia un peritaje nuevo para el siniestro indicado (limpia el borrador).
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

  /// Guarda el peritaje (`PUT`) y lo confirma (`POST`). Marca `resultado` al ok.
  Future<bool> guardarYConfirmar() async {
    if (!state.puedeConfirmar) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      await ref.read(guardarPeritajeProvider)(
        siniestroId: state.siniestroId,
        costoDefinitivo: state.costoDefinitivo,
        firmaDigitalBase64: state.firmaBase64!,
        danos: state.danos,
        observacionesCampo:
            state.observaciones.trim().isEmpty ? null : state.observaciones.trim(),
      );
      final siniestro =
          await ref.read(confirmarPeritajeProvider)(state.siniestroId);
      state = state.copyWith(submitting: false, resultado: siniestro);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
      return false;
    }
  }
}

final peritajeEditorProvider =
    NotifierProvider<PeritajeEditorController, PeritajeEditorState>(
        PeritajeEditorController.new);
