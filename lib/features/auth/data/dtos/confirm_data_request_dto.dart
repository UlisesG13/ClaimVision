/// Cuerpo de `POST /api/cliente/onboarding/confirmar-datos`
/// (`ConfirmDataRequestDTO`). Campos verbatim del backend.
class ConfirmDataRequestDto {
  const ConfirmDataRequestDto({
    required this.numeroPoliza,
    required this.vigenciaPoliza,
    required this.curpRfc,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.vehiculoAnio,
    required this.vehiculoPlacas,
  });

  final String numeroPoliza;
  final String vigenciaPoliza;
  final String curpRfc;
  final String vehiculoMarca;
  final String vehiculoModelo;
  final int vehiculoAnio;
  final String vehiculoPlacas;

  Map<String, dynamic> toJson() => {
        'numero_poliza': numeroPoliza,
        'vigencia_poliza': vigenciaPoliza,
        'curp_rfc': curpRfc,
        'vehiculo_marca': vehiculoMarca,
        'vehiculo_modelo': vehiculoModelo,
        'vehiculo_anio': vehiculoAnio,
        'vehiculo_placas': vehiculoPlacas,
      };
}
