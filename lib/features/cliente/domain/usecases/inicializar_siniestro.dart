import 'package:claimvision/shared/domain/entities/siniestro.dart';
import '../repositories/siniestro_repository.dart';

class InicializarSiniestro {
  const InicializarSiniestro(this._repository);

  final SiniestroRepository _repository;

  Future<Siniestro> call({
    required String vehiculoId,
    required String vehiculoMarca,
    required String vehiculoModelo,
    required int vehiculoAnio,
    required String vehiculoPlacas,
    required double latitud,
    required double longitud,
    String? vehiculoVin,
    String? narracionTexto,
    String? narracionAudioUrl,
    bool? indicacionesDanoInterno,
    DateTime? fechaSiniestro,
  }) {
    return _repository.crear(
      vehiculoId: vehiculoId,
      vehiculoMarca: vehiculoMarca,
      vehiculoModelo: vehiculoModelo,
      vehiculoAnio: vehiculoAnio,
      vehiculoPlacas: vehiculoPlacas,
      latitud: latitud,
      longitud: longitud,
      vehiculoVin: vehiculoVin,
      narracionTexto: narracionTexto,
      narracionAudioUrl: narracionAudioUrl,
      indicacionesDanoInterno: indicacionesDanoInterno,
      fechaSiniestro: fechaSiniestro,
    );
  }
}
