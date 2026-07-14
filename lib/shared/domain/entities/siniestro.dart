import 'siniestro_estatus.dart';

class Siniestro {
  const Siniestro({
    required this.id,
    required this.aseguradoraId,
    required this.clienteId,
    required this.estatus,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoAnio,
    required this.vehiculoPlacas,
    required this.latitud,
    required this.longitud,
    required this.indicacionesDanoInterno,
    required this.fechaSiniestro,
    required this.createdAt,
    this.ajustadorId,
    this.tallerId,
    this.vehiculoVin,
    this.narracionTexto,
    this.narracionAudioUrl,
  });

  final String id;
  final String aseguradoraId;
  final String clienteId;
  final String? ajustadorId;
  final String? tallerId;
  final SiniestroEstatus estatus;

  final String vehiculoMarca;
  final String vehiculoModelo;
  final int vehiculoAnio;
  final String vehiculoPlacas;
  final String? vehiculoVin;

  final double latitud;
  final double longitud;
  final String? narracionTexto;
  final String? narracionAudioUrl;
  final bool indicacionesDanoInterno;

  final DateTime fechaSiniestro;
  final DateTime createdAt;

  /// Etiqueta corta del vehículo: "Toyota RAV4 2023 · GTX-441".
  String get vehiculoResumen =>
      '$vehiculoMarca $vehiculoModelo $vehiculoAnio · $vehiculoPlacas';

  /// Folio corto y legible derivado del id (p. ej. "#CV-8472").
  String get folioCorto {
    final limpio = id.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    final cola =
        limpio.length <= 6 ? limpio : limpio.substring(limpio.length - 6);
    return '#CV-${cola.toUpperCase()}';
  }
}
