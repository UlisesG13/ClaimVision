import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/ia/data/dtos/ia_batch_dto.dart';
import '../../../../core/ia/data/dtos/ia_nlp_dto.dart';
import '../../domain/entities/vehiculo_cliente.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'mis_siniestros_controller.dart';

class Evidencia {
  const Evidencia({
    required this.file,
    this.subiendo = false,
    this.calidadValida,
    this.error,
    this.imagenId,
    this.tipoDano,
    this.severidad,
    this.confianza,
    this.predicting = false,
  });

  final File file;
  final bool subiendo;
  final bool? calidadValida;
  final String? error;
  final String? imagenId;
  final String? tipoDano;
  final String? severidad;
  final double? confianza;
  final bool predicting;

  bool get prediccionLista => tipoDano != null;

  Evidencia copyWith({
    bool? subiendo,
    bool? calidadValida,
    String? error,
    String? imagenId,
    String? tipoDano,
    String? severidad,
    double? confianza,
    bool? predicting,
    bool clearError = false,
  }) {
    return Evidencia(
      file: file,
      subiendo: subiendo ?? this.subiendo,
      calidadValida: calidadValida ?? this.calidadValida,
      error: clearError ? null : (error ?? this.error),
      imagenId: imagenId ?? this.imagenId,
      tipoDano: tipoDano ?? this.tipoDano,
      severidad: severidad ?? this.severidad,
      confianza: confianza ?? this.confianza,
      predicting: predicting ?? this.predicting,
    );
  }
}

class ReportState {
  const ReportState({
    this.vehiculoId = '',
    this.marca = '',
    this.modelo = '',
    this.anio = '',
    this.placas = '',
    this.vin = '',
    this.vehiculoSeleccionado,
    this.latitud,
    this.longitud,
    this.narracionTexto = '',
    this.danoInterno = false,
    this.evidencias = const [],
    this.siniestro,
    this.submitting = false,
    this.audioFile,
    this.transcribiendo = false,
    this.transcripcion,
    this.analizando = false,
    this.analisisEntidades = const [],
    this.prediccionesFotos = const [],
    this.predictandoBatch = false,
    this.calculandoCosto = false,
    this.resumenCosto,
    this.errorMessage,
  });

  final String vehiculoId;
  final String marca;
  final String modelo;
  final String anio;
  final String placas;
  final String vin;
  final VehiculoCliente? vehiculoSeleccionado;
  final double? latitud;
  final double? longitud;
  final String narracionTexto;
  final bool danoInterno;
  final List<Evidencia> evidencias;
  final Siniestro? siniestro;
  final bool submitting;
  final File? audioFile;
  final bool transcribiendo;
  final String? transcripcion;
  final bool analizando;
  final List<IaDamageEntityDto> analisisEntidades;
  final List<IaDamageEntityDto> prediccionesFotos;
  final bool predictandoBatch;
  final bool calculandoCosto;
  final IaResumenResponseDto? resumenCosto;
  final String? errorMessage;

  bool get vehiculoCompleto =>
      vehiculoId.isNotEmpty &&
      marca.trim().isNotEmpty &&
      modelo.trim().isNotEmpty &&
      placas.trim().isNotEmpty &&
      int.tryParse(anio.trim()) != null;

  bool get ubicacionLista => latitud != null && longitud != null;
  bool get yaCreado => siniestro != null;

  int get evidenciasValidas =>
      evidencias.where((e) => e.calidadValida == true).length;
  bool get subiendoAlguna => evidencias.any((e) => e.subiendo);

  bool get puedeEnviar =>
      yaCreado && evidenciasValidas > 0 && !subiendoAlguna;

  ReportState copyWith({
    String? vehiculoId,
    String? marca,
    String? modelo,
    String? anio,
    String? placas,
    String? vin,
    VehiculoCliente? vehiculoSeleccionado,
    double? latitud,
    double? longitud,
    String? narracionTexto,
    bool? danoInterno,
    List<Evidencia>? evidencias,
    Siniestro? siniestro,
    bool? submitting,
    File? audioFile,
    bool? transcribiendo,
    String? transcripcion,
    bool? analizando,
    List<IaDamageEntityDto>? analisisEntidades,
    List<IaDamageEntityDto>? prediccionesFotos,
    bool? predictandoBatch,
    bool? calculandoCosto,
    IaResumenResponseDto? resumenCosto,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      vehiculoId: vehiculoId ?? this.vehiculoId,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      placas: placas ?? this.placas,
      vin: vin ?? this.vin,
      vehiculoSeleccionado: vehiculoSeleccionado ?? this.vehiculoSeleccionado,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      narracionTexto: narracionTexto ?? this.narracionTexto,
      danoInterno: danoInterno ?? this.danoInterno,
      evidencias: evidencias ?? this.evidencias,
      siniestro: siniestro ?? this.siniestro,
      submitting: submitting ?? this.submitting,
      audioFile: audioFile ?? this.audioFile,
      transcribiendo: transcribiendo ?? this.transcribiendo,
      transcripcion: transcripcion ?? this.transcripcion,
      analizando: analizando ?? this.analizando,
      analisisEntidades: analisisEntidades ?? this.analisisEntidades,
      prediccionesFotos: prediccionesFotos ?? this.prediccionesFotos,
      predictandoBatch: predictandoBatch ?? this.predictandoBatch,
      calculandoCosto: calculandoCosto ?? this.calculandoCosto,
      resumenCosto: resumenCosto ?? this.resumenCosto,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ReportController extends Notifier<ReportState> {
  Timer? _debounceBatch;

  @override
  ReportState build() {
    ref.onDispose(() => _debounceBatch?.cancel());
    return const ReportState();
  }

  void reset() => state = const ReportState();

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

  void setNarracion(String texto) => state = state.copyWith(narracionTexto: texto);
  void setDanoInterno(bool value) => state = state.copyWith(danoInterno: value);

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
        final status = await ref.read(iaRepositoryProvider).transcribirStatus(job.jobId);
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
}

final reportControllerProvider =
    NotifierProvider<ReportController, ReportState>(ReportController.new);
