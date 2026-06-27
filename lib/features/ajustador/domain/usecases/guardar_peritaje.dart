import '../entities/dano_ajustado.dart';
import '../entities/peritaje.dart';
import '../repositories/peritaje_repository.dart';

/// Caso de uso: guardar/actualizar el peritaje del ajustador.
class GuardarPeritaje {
  const GuardarPeritaje(this._repository);

  final PeritajeRepository _repository;

  Future<Peritaje> call({
    required String siniestroId,
    required double costoDefinitivo,
    required String firmaDigitalBase64,
    required List<DanoAjustado> danos,
    String? observacionesCampo,
  }) {
    return _repository.guardarPeritaje(
      siniestroId: siniestroId,
      costoDefinitivo: costoDefinitivo,
      firmaDigitalBase64: firmaDigitalBase64,
      danos: danos,
      observacionesCampo: observacionesCampo,
    );
  }
}
