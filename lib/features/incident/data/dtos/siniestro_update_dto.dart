/// Cuerpo de `PUT /api/siniestros/{id}` (`SiniestroUpdateDTO`). Todos los
/// campos son opcionales; solo se envían los que cambian (update parcial).
class SiniestroUpdateDto {
  const SiniestroUpdateDto({
    this.vehiculoMarca,
    this.vehiculoModelo,
    this.vehiculoAnio,
    this.vehiculoPlacas,
    this.vehiculoVin,
    this.latitud,
    this.longitud,
    this.narracionTexto,
    this.narracionAudioUrl,
    this.indicacionesDanoInterno,
  });

  final String? vehiculoMarca;
  final String? vehiculoModelo;
  final int? vehiculoAnio;
  final String? vehiculoPlacas;
  final String? vehiculoVin;
  final double? latitud;
  final double? longitud;
  final String? narracionTexto;
  final String? narracionAudioUrl;
  final bool? indicacionesDanoInterno;

  Map<String, dynamic> toJson() => {
        if (vehiculoMarca != null) 'vehiculo_marca': vehiculoMarca,
        if (vehiculoModelo != null) 'vehiculo_modelo': vehiculoModelo,
        if (vehiculoAnio != null) 'vehiculo_anio': vehiculoAnio,
        if (vehiculoPlacas != null) 'vehiculo_placas': vehiculoPlacas,
        if (vehiculoVin != null) 'vehiculo_vin': vehiculoVin,
        if (latitud != null) 'latitud_siniestro': latitud,
        if (longitud != null) 'longitud_siniestro': longitud,
        if (narracionTexto != null) 'narracion_texto': narracionTexto,
        if (narracionAudioUrl != null) 'narracion_audio_url': narracionAudioUrl,
        if (indicacionesDanoInterno != null)
          'indicaciones_dano_interno': indicacionesDanoInterno,
      };
}
