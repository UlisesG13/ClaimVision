import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../repositories/peritaje_repository.dart';

/// Caso de uso: obtener los siniestros asignados al ajustador.
class GetCasosAsignados {
  const GetCasosAsignados(this._repository);

  final PeritajeRepository _repository;

  Future<List<Siniestro>> call() => _repository.getCasosAsignados();
}
