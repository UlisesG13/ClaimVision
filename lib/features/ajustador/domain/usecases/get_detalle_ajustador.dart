import 'package:claimvision/shared/domain/entities/siniestro.dart';
import '../repositories/peritaje_repository.dart';

class GetDetalleAjustador {
  const GetDetalleAjustador(this._repository);

  final PeritajeRepository _repository;

  Future<Siniestro> call(String id) => _repository.obtenerDetalleSiniestro(id);
}
