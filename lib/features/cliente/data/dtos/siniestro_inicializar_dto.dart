class SiniestroInicializarDto {
  const SiniestroInicializarDto({
    required this.vehiculoId,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoAnio,
    required this.vehiculoPlacas,
    required this.latitud,
    required this.longitud,
    this.vehiculoVin,
    this.narracionTexto,
    this.narracionAudioUrl,
    this.indicacionesDanoInterno,
    this.fechaSiniestro,
  });

  final String vehiculoId;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final int vehiculoAnio;
  final String vehiculoPlacas;
  final String? vehiculoVin;
  final double latitud;
  final double longitud;
  final String? narracionTexto;
  final String? narracionAudioUrl;
  final bool? indicacionesDanoInterno;
  final DateTime? fechaSiniestro;

  Map<String, dynamic> toJson() => {
        'vehiculo_id': vehiculoId,
        'vehiculo_marca': vehiculoMarca,
        'vehiculo_modelo': vehiculoModelo,
        'vehiculo_anio': vehiculoAnio,
        'vehiculo_placas': vehiculoPlacas,
        'latitud_siniestro': latitud,
        'longitud_siniestro': longitud,
        if (vehiculoVin != null && vehiculoVin!.isNotEmpty)
          'vehiculo_vin': vehiculoVin,
        if (narracionTexto != null && narracionTexto!.isNotEmpty)
          'narracion_texto': narracionTexto,
        if (narracionAudioUrl != null && narracionAudioUrl!.isNotEmpty)
          'narracion_audio_url': narracionAudioUrl,
        if (indicacionesDanoInterno != null)
          'indicaciones_dano_interno': indicacionesDanoInterno,
        if (fechaSiniestro != null)
          'fecha_siniestro': fechaSiniestro!.toIso8601String(),
      };
}
