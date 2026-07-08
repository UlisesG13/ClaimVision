import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../repositories/siniestro_repository.dart';

class GetSiniestroDetalle {
  const GetSiniestroDetalle(this._repository);

  final SiniestroRepository _repository;

  Future<Siniestro> call(String id) {
    return _repository.obtener(id);
  }
}
