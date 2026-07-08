import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'mis_siniestros_provider.dart';

/// Una foto del daño en el paso de Captura (#8): el archivo local más el
/// estado de su subida al backend y el resultado de la validación de calidad.
class Evidencia {
  const Evidencia({
    required this.file,
    this.subiendo = false,
    this.calidadValida,
    this.error,
    this.imagenId,
  });

  final File file;
  final bool subiendo;

  /// `true`/`false` tras subir (de `es_calidad_valida`); `null` si aún no sube
  /// o si falló.
  final bool? calidadValida;
  final String? error;
  final String? imagenId;

  Evidencia copyWith({
    bool? subiendo,
    bool? calidadValida,
    String? error,
    String? imagenId,
    bool clearError = false,
  }) {
    return Evidencia(
      file: file,
      subiendo: subiendo ?? this.subiendo,
      calidadValida: calidadValida ?? this.calidadValida,
      error: clearError ? null : (error ?? this.error),
      imagenId: imagenId ?? this.imagenId,
    );
  }
}

/// Borrador del reporte de siniestro a lo largo del wizard (pasos #5–#9).
///
/// Flujo de red:
///  - Paso Vehículo (#5) + Ubicación (#6) → `crearSiniestro()` llama a
///    `POST /siniestros/inicializar` (necesita vehículo + ubicación juntos).
///  - Narración (#7) → `guardarNarracion()` (`PUT /siniestros/{id}`).
///  - Captura (#8) → `subirImagenes()` (`POST /siniestros/{id}/imagenes`).
class ReportState {
  const ReportState({
    this.marca = '',
    this.modelo = '',
    this.anio = '',
    this.placas = '',
    this.vin = '',
    this.latitud,
    this.longitud,
    this.narracionTexto = '',
    this.danoInterno = false,
    this.evidencias = const [],
    this.siniestro,
    this.submitting = false,
    this.errorMessage,
  });

  // Vehículo (#5)
  final String marca;
  final String modelo;
  final String anio;
  final String placas;
  final String vin;

  // Ubicación (#6)
  final double? latitud;
  final double? longitud;

  // Narración (#7)
  final String narracionTexto;
  final bool danoInterno;

  // Captura (#8)
  final List<Evidencia> evidencias;

  /// Siniestro ya creado en el backend (tras `crearSiniestro`).
  final Siniestro? siniestro;

  final bool submitting;
  final String? errorMessage;

  bool get vehiculoCompleto =>
      marca.trim().isNotEmpty &&
      modelo.trim().isNotEmpty &&
      placas.trim().isNotEmpty &&
      int.tryParse(anio.trim()) != null;

  bool get ubicacionLista => latitud != null && longitud != null;
  bool get yaCreado => siniestro != null;

  int get evidenciasValidas =>
      evidencias.where((e) => e.calidadValida == true).length;
  bool get subiendoAlguna => evidencias.any((e) => e.subiendo);

  /// Se puede enviar el reporte cuando el siniestro existe, hay al menos una
  /// foto con calidad válida y ninguna sigue subiendo.
  bool get puedeEnviar =>
      yaCreado && evidenciasValidas > 0 && !subiendoAlguna;

  ReportState copyWith({
    String? marca,
    String? modelo,
    String? anio,
    String? placas,
    String? vin,
    double? latitud,
    double? longitud,
    String? narracionTexto,
    bool? danoInterno,
    List<Evidencia>? evidencias,
    Siniestro? siniestro,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportState(
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      placas: placas ?? this.placas,
      vin: vin ?? this.vin,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      narracionTexto: narracionTexto ?? this.narracionTexto,
      danoInterno: danoInterno ?? this.danoInterno,
      evidencias: evidencias ?? this.evidencias,
      siniestro: siniestro ?? this.siniestro,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ReportController extends Notifier<ReportState> {
  @override
  ReportState build() => const ReportState();

  /// Reinicia el borrador al iniciar un nuevo reporte.
  void reset() => state = const ReportState();

  void setVehiculo({
    required String marca,
    required String modelo,
    required String anio,
    required String placas,
    required String vin,
  }) {
    state = state.copyWith(
      marca: marca,
      modelo: modelo,
      anio: anio,
      placas: placas,
      vin: vin,
      clearError: true,
    );
  }

  void setUbicacion({required double latitud, required double longitud}) {
    state = state.copyWith(
        latitud: latitud, longitud: longitud, clearError: true);
  }

  void setNarracion(String texto) => state = state.copyWith(narracionTexto: texto);
  void setDanoInterno(bool value) => state = state.copyWith(danoInterno: value);

  /// Agrega una foto y la sube de inmediato; el backend devuelve si la calidad
  /// es válida (`es_calidad_valida`), que mostramos por miniatura.
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
      _reemplazar(
        nueva,
        nueva.copyWith(
          subiendo: false,
          calidadValida: imagen.esCalidadValida,
          imagenId: imagen.id,
          clearError: true,
        ),
      );
    } on Failure catch (f) {
      _reemplazar(nueva, nueva.copyWith(subiendo: false, error: f.message));
    }
  }

  void quitarEvidencia(Evidencia evidencia) {
    state = state.copyWith(
      evidencias: state.evidencias.where((e) => e != evidencia).toList(),
    );
  }

  void _reemplazar(Evidencia vieja, Evidencia nueva) {
    state = state.copyWith(
      evidencias: [
        for (final e in state.evidencias)
          if (identical(e, vieja)) nueva else e,
      ],
    );
  }

  /// Crea el siniestro preliminar (vehículo + ubicación). Devuelve `true` si ok.
  Future<bool> crearSiniestro() async {
    if (state.yaCreado) return true;
    if (!state.vehiculoCompleto || !state.ubicacionLista) {
      state = state.copyWith(
          errorMessage: 'Faltan datos del vehículo o la ubicación.');
      return false;
    }
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final siniestro = await ref.read(inicializarSiniestroProvider)(
        vehiculoMarca: state.marca.trim(),
        vehiculoModelo: state.modelo.trim(),
        vehiculoAnio: int.parse(state.anio.trim()),
        vehiculoPlacas: state.placas.trim(),
        latitud: state.latitud!,
        longitud: state.longitud!,
        vehiculoVin: state.vin.trim().isEmpty ? null : state.vin.trim(),
        narracionTexto:
            state.narracionTexto.trim().isEmpty ? null : state.narracionTexto.trim(),
      );
      ref.read(misSiniestrosProvider.notifier).refrescar();
      state = state.copyWith(submitting: false, siniestro: siniestro);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
      return false;
    }
  }

  /// Guarda la narración y el indicador de daño interno (`PUT`).
  Future<bool> guardarNarracion() async {
    final siniestro = state.siniestro;
    if (siniestro == null) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final actualizado = await ref.read(actualizarSiniestroProvider)(
        id: siniestro.id,
        narracionTexto:
            state.narracionTexto.trim().isEmpty ? null : state.narracionTexto.trim(),
        indicacionesDanoInterno: state.danoInterno,
      );
      ref.read(misSiniestrosProvider.notifier).refrescar();
      state = state.copyWith(submitting: false, siniestro: actualizado);
      return true;
    } on Failure catch (f) {
      state = state.copyWith(submitting: false, errorMessage: f.message);
      return false;
    }
  }

}

final reportControllerProvider =
    NotifierProvider<ReportController, ReportState>(ReportController.new);
