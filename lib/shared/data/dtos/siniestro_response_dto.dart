/// Respuesta de los endpoints de siniestros (`SiniestroResponseDTO`).
/// Campos verbatim del backend. Compartido entre cliente y ajustador.
class SiniestroResponseDto {
  const SiniestroResponseDto({
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
  final String estatus;
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

  factory SiniestroResponseDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    DateTime toDate(dynamic v) =>
        DateTime.tryParse('$v')?.toLocal() ?? DateTime.now();

    return SiniestroResponseDto(
      id: json['id'].toString(),
      aseguradoraId: (json['aseguradora_id'] ?? '').toString(),
      clienteId: (json['cliente_id'] ?? '').toString(),
      ajustadorId: json['ajustador_id'] as String?,
      tallerId: json['taller_id'] as String?,
      estatus: (json['estatus'] ?? '').toString(),
      vehiculoMarca: (json['vehiculo_marca'] ?? '').toString(),
      vehiculoModelo: (json['vehiculo_modelo'] ?? '').toString(),
      vehiculoAnio: toInt(json['vehiculo_anio']),
      vehiculoPlacas: (json['vehiculo_placas'] ?? '').toString(),
      vehiculoVin: json['vehiculo_vin'] as String?,
      latitud: toDouble(json['latitud_siniestro']),
      longitud: toDouble(json['longitud_siniestro']),
      narracionTexto: json['narracion_texto'] as String?,
      narracionAudioUrl: json['narracion_audio_url'] as String?,
      indicacionesDanoInterno: json['indicaciones_dano_interno'] == true,
      fechaSiniestro: toDate(json['fecha_siniestro']),
      createdAt: toDate(json['created_at']),
    );
  }
}
