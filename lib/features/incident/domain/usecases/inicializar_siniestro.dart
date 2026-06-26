import '../entities/siniestro.dart';
import '../repositories/siniestro_repository.dart';

/// Caso de uso: crear el siniestro preliminar con vehículo + ubicación.
class InicializarSiniestro {
  const InicializarSiniestro(this._repository);

  final SiniestroRepository _repository;

  Future<Siniestro> call({
    required String vehiculoMarca,
    required String vehiculoModelo,
    required int vehiculoAnio,
    required String vehiculoPlacas,
    required double latitud,
    required double longitud,
    String? vehiculoVin,
    String? narracionTexto,
  }) {
    return _repository.inicializar(
      vehiculoMarca: vehiculoMarca,
      vehiculoModelo: vehiculoModelo,
      vehiculoAnio: vehiculoAnio,
      vehiculoPlacas: vehiculoPlacas,
      latitud: latitud,
      longitud: longitud,
      vehiculoVin: vehiculoVin,
      narracionTexto: narracionTexto,
    );
  }
}
