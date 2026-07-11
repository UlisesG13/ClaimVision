import '../entities/dano_ajustado.dart';
import '../entities/peritaje.dart';
import '../repositories/peritaje_repository.dart';

class RegistrarPeritaje {
  const RegistrarPeritaje(this._repository);

  final PeritajeRepository _repository;

  Future<Peritaje> call({
    required String siniestroId,
    required double costoDefinitivo,
    required String firmaDigitalBase64,
    required List<DanoAjustado> danos,
    String? observacionesCampo,
  }) {
    return _repository.registrarPeritaje(
      siniestroId: siniestroId,
      costoDefinitivo: costoDefinitivo,
      firmaDigitalBase64: firmaDigitalBase64,
      danos: danos,
      observacionesCampo: observacionesCampo,
    );
  }
}
