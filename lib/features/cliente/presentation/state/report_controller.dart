import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import 'providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/ia/data/dtos/ia_nlp_dto.dart';
import '../../domain/entities/vehiculo_cliente.dart';
import 'report_state.dart';
import 'mis_siniestros_controller.dart';

export 'report_state.dart' show Evidencia, ReportState;

/// Controller principal del flujo de reporte de siniestro.
///
/// Organizado en secciones lógicas:
/// 1. **Formulario**: datos del vehículo, ubicación, narración
/// 2. **Evidencias**: fotos, audio, transcripciones
/// 3. **Análisis IA**: NLP, predicciones, resumen de costo
/// 4. **Creación**: inicialización del siniestro en backend
///
/// Todas las mutaciones de estado pasan por [ReportState.copyWith] para
/// mantener inmutabilidad y reactividad.
class ReportController extends Notifier<ReportState> {
  Timer? _debounceBatch;

  @override
  ReportState build() {
    ref.onDispose(() => _debounceBatch?.cancel());
    return const ReportState();
  }

  /// Reinicia todo el flujo de reporte.
  void reset() => state = const ReportState();

  // ═════════════════════════════════════════════════════════════════════════
  // SECCIÓN 1: FORMULARIO (vehículo, ubicación, narración)
  // ═════════════════════════════════════════════════════════════════════════

  void setVehiculo({
    required String vehiculoId,
    required String marca,
    required String modelo,
    required int anio,
    required String placas,
    String? vin,
    VehiculoCliente? vehiculoSeleccionado,
  }) {
    state = state.copyWith(
      vehiculoId: vehiculoId,
      marca: marca,
      modelo: modelo,
      anio: anio.toString(),
      placas: placas,
      vin: vin ?? '',
      vehiculoSeleccionado: vehiculoSeleccionado,
      clearError: true,
    );
  }

  void setUbicacion({required double latitud, required double longitud}) {
    state = state.copyWith(
        latitud: latitud, longitud: longitud, clearError: true);
  }

  void setNarracion(String texto) =>
      state = state.copyWith(narracionTexto: texto);

  void setDanoInterno(bool value) =>
      state = state.copyWith(danoInterno: value);

  // ═════════════════════════════════════════════════════════════════════════
  // SECCIÓN 2: EVIDENCIAS (fotos, audio, transcripciones)
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> subirEvidencia(File file) async {
    final siniestro = state.siniestro;
    if (siniestro == null) {
      state = state.copyWith(
          errorMessage: 'Primero registra la ubicación del siniestro.');
      return;
    }
    final nueva = Evidencia(file: file, subiendo: true);
    state = state.copyWith(evidencias: [...state.evidencias, nueva]);

    try {
      final imagen = await ref.read(subirImagenSiniestroProvider)(
        id: siniestro.id,
        imagen: file,
      );
      final actualizada = nueva.copyWith(
        subiendo: false,
        calidadValida: imagen.esCalidadValida,
        imagenId: imagen.id,
        clearError: true,
      );
      _reemplazar(nueva, actualizada);
      _programarBatchAuto();
    } on Failure catch (f) {
      _reemplazar(nueva, nueva.copyWith(subiendo: false, error: f.message));
    }
  }

  void _programarBatchAuto() {
    _debounceBatch?.cancel();
    _debounceBatch = Timer(const Duration(milliseconds: 1500), predecirTodasLasFotos);
  }

  Future<void> predecirTodasLasFotos() async {
    final pendientes =
        state.evidencias.where((e) => e.tipoDano == null).toList();
    if (pendientes.isEmpty) return;
    state = state.copyWith(predictandoBatch: true);
    try {
      final result = await ref.read(iaPredictAllDamageProvider)(
        files: pendientes.map((e) => e.file).toList(),
      );
      for (final item in result.predicciones) {
        final match = state.evidencias.where(
          (e) => e.file.path.split(RegExp(r'[\\/]')).last == item.filename,
        );
        for (final ev in match) {
          _reemplazar(
            ev,
            ev.copyWith(
              tipoDano: item.tipoDano,
              severidad: item.severidad,
              confianza: item.confianza,
            ),
          );
        }
      }
    } catch (_) {
      // silencioso — cada foto se puede procesar individualmente después
    } finally {
      state = state.copyWith(predictandoBatch: false);
    }
  }

  void quitarEvidencia(Evidencia evidencia) {
    state = state.copyWith(
      evidencias: state.evidencias.where((e) => e != evidencia).toList(),
    );
  }

  void _reemplazar(Evidencia vieja, Evidencia nueva) {
    final nuevasEvidencias = [
      for (final e in state.evidencias)
        if (identical(e, vieja)) nueva else e,
    ];
    state = state.copyWith(
      evidencias: nuevasEvidencias,
      prediccionesFotos: [
        for (final e in nuevasEvidencias)
          if (e.tipoDano != null)
            IaDamageEntityDto(
              tipoDano: e.tipoDano!,
              severidad: e.severidad ?? 'desconocida',
              parteAfectada: 'Foto',
              sintoma: e.confianza != null
                  ? '${(e.confianza! * 100).toStringAsFixed(0)}% confianza'
                  : '',
              confianza: e.confianza ?? 0,
            ),
      ],
    );
  }

  void setAudioFile(File? file) => state = state.copyWith(audioFile: file);

  void setTranscripcion(String? texto) =>
      state = state.copyWith(transcripcion: texto, transcribiendo: false);

  Future<void> transcribirAudio() async {
    final file = state.audioFile;
    if (file == null) return;
    state = state.copyWith(transcribiendo: true, clearError: true);
    try {
      final job = await ref.read(iaTranscribirAudioProvider)(file: file);
      const maxPolls = 30;
      for (var i = 0; i < maxPolls; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final status = await ref.read(iaTranscribirStatusProvider)(job.jobId);
        if (status.status == 'completed') {
          state = state.copyWith(
            transcripcion: status.result?.texto,
            transcribiendo: false,
          );
          return;
        }
        if (status.status == 'failed') {
          state = state.copyWith(
            transcribiendo: false,
            errorMessage: status.error,
          );
          return;
        }
      }
      state = state.copyWith(transcribiendo: false);
    } on Failure catch (f) {
      state = state.copyWith(transcribiendo: false, errorMessage: f.message);
    } catch (e) {
      state = state.copyWith(
        transcribiendo: false,
        errorMessage: 'Error al transcribir audio: $e',
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SECCIÓN 3: ANÁLISIS IA (NLP, predicciones, resumen de costo)
  // ═════════════════════════════════════════════════════════════════════════

  Future<void> analizarTexto() async {
    final texto = (state.transcripcion?.isNotEmpty == true)
        ? state.transcripcion!
        : state.narracionTexto;
    if (texto.trim().isEmpty) return;
    state = state.copyWith(analizando: true, clearError: true);
    try {
      final result = await ref.read(iaAnalizarTextoProvider)(texto.trim());
      state = state.copyWith(
        analizando: false,
        analisisEntidades: result.entidades,
      );
      await obtenerResumenCosto();
    } on Failure catch (f) {
      state = state.copyWith(analizando: false, errorMessage: f.message);
    } catch (e) {
      state = state.copyWith(
        analizando: false,
        errorMessage: 'Error al analizar texto: $e',
      );
    }
  }

  Future<void> obtenerResumenCosto() async {
    final danos = <({String tipo, String severidad})>{};
    for (final e in state.evidencias) {
      if (e.tipoDano != null && e.severidad != null) {
        danos.add((tipo: e.tipoDano!, severidad: e.severidad!));
      }
    }
    for (final ent in state.analisisEntidades) {
      danos.add((tipo: ent.tipoDano, severidad: ent.severidad));
    }
    if (danos.isEmpty) return;
    state = state.copyWith(calculandoCosto: true, clearError: true);
    try {
      final resumen = await ref.read(iaObtenerResumenProvider)(
        danos: danos.toList(),
      );
      state = state.copyWith(calculandoCosto: false, resumenCosto: resumen);
    } on Failure catch (f) {
      state = state.copyWith(calculandoCosto: false, errorMessage: f.message);
    } catch (e) {
      state = state.copyWith(
        calculandoCosto: false,
        errorMessage: 'Error al calcular costo: $e',
      );
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // SECCIÓN 4: CREACIÓN DE SINIESTRO
  // ═════════════════════════════════════════════════════════════════════════

  Future<bool> crearSiniestro() async {
    if (state.yaCreado || state.submitting) return state.yaCreado;
    if (!state.vehiculoCompleto || !state.ubicacionLista) {
      state = state.copyWith(
          errorMessage: 'Faltan datos del vehículo o la ubicación.');
      return false;
    }
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final siniestro = await ref.read(inicializarSiniestroProvider)(
        vehiculoId: state.vehiculoId,
        vehiculoMarca: state.marca.trim(),
        vehiculoModelo: state.modelo.trim(),
        vehiculoAnio: int.parse(state.anio.trim()),
        vehiculoPlacas: state.placas.trim(),
        latitud: state.latitud!,
        longitud: state.longitud!,
        vehiculoVin: state.vin.trim().isEmpty ? null : state.vin.trim(),
        narracionTexto:
            state.narracionTexto.trim().isEmpty ? null : state.narracionTexto.trim(),
        indicacionesDanoInterno: state.danoInterno,
      );
      ref.read(misSiniestrosControllerProvider.notifier).refrescar();
      state = state.copyWith(submitting: false, siniestro: siniestro);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
      return false;
    }
  }
}

final reportControllerProvider =
    NotifierProvider<ReportController, ReportState>(ReportController.new);
