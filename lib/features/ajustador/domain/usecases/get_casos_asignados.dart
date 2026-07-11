import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../repositories/peritaje_repository.dart';

class GetCasosAsignados {
  const GetCasosAsignados(this._repository);

  final PeritajeRepository _repository;

  Future<List<Siniestro>> call({int page = 1, int pageSize = 20, String? estatus}) =>
      _repository.getCasosAsignados(page: page, pageSize: pageSize, estatus: estatus);
}
