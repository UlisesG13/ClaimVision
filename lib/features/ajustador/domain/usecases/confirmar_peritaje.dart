import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../repositories/peritaje_repository.dart';

/// Caso de uso: confirmar y bloquear el peritaje definitivo.
class ConfirmarPeritaje {
  const ConfirmarPeritaje(this._repository);

  final PeritajeRepository _repository;

  Future<Siniestro> call(String siniestroId) =>
      _repository.confirmarPeritaje(siniestroId);
}
