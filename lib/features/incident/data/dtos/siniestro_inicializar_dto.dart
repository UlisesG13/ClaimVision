/// Cuerpo de `POST /api/siniestros/inicializar` (`SiniestroInicializarDTO`).
/// Campos verbatim del backend.
class SiniestroInicializarDto {
  const SiniestroInicializarDto({
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoAnio,
    required this.vehiculoPlacas,
    required this.latitud,
    required this.longitud,
    this.vehiculoVin,
    this.narracionTexto,
  });

  final String vehiculoMarca;
  final String vehiculoModelo;
  final int vehiculoAnio;
  final String vehiculoPlacas;
  final String? vehiculoVin;
  final double latitud;
  final double longitud;
  final String? narracionTexto;

  Map<String, dynamic> toJson() => {
        'vehiculo_marca': vehiculoMarca,
        'vehiculo_modelo': vehiculoModelo,
        'vehiculo_anio': vehiculoAnio,
        'vehiculo_placas': vehiculoPlacas,
        if (vehiculoVin != null && vehiculoVin!.isNotEmpty)
          'vehiculo_vin': vehiculoVin,
        'latitud_siniestro': latitud,
        'longitud_siniestro': longitud,
        if (narracionTexto != null && narracionTexto!.isNotEmpty)
          'narracion_texto': narracionTexto,
      };
}
