import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../repositories/siniestro_repository.dart';

class GetSiniestrosCliente {
  const GetSiniestrosCliente(this._repository);

  final SiniestroRepository _repository;

  Future<List<Siniestro>> call() {
    return _repository.listar();
  }
}
