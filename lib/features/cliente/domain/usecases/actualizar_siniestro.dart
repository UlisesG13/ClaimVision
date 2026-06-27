import 'package:claimvision/shared/domain/entities/siniestro.dart';
import '../repositories/siniestro_repository.dart';

/// Caso de uso: actualizar campos del siniestro (narración, daño interno…).
class ActualizarSiniestro {
  const ActualizarSiniestro(this._repository);

  final SiniestroRepository _repository;

  Future<Siniestro> call({
    required String id,
    String? narracionTexto,
    bool? indicacionesDanoInterno,
  }) {
    return _repository.actualizar(
      id: id,
      narracionTexto: narracionTexto,
      indicacionesDanoInterno: indicacionesDanoInterno,
    );
  }
}
