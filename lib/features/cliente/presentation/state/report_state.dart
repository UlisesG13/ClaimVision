import 'dart:io';

import '../../../../core/ia/data/dtos/ia_batch_dto.dart';
import '../../../../core/ia/data/dtos/ia_nlp_dto.dart';
import '../../domain/entities/vehiculo_cliente.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';

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
