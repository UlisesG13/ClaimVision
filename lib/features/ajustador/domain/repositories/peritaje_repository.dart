import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../entities/dano_ajustado.dart';
import '../entities/perfil_ajustador.dart';
import '../entities/peritaje.dart';

/// Contrato del flujo del ajustador (peritaje). Lanza `Failure` ante error.
abstract interface class PeritajeRepository {
  /// Casos (siniestros) asignados al ajustador autenticado.
  Future<List<Siniestro>> getCasosAsignados();

  /// Guarda/actualiza el peritaje del siniestro (daños, costo, firma).
  Future<Peritaje> guardarPeritaje({
    required String siniestroId,
    required double costoDefinitivo,
    required String firmaDigitalBase64,
    required List<DanoAjustado> danos,
    String? observacionesCampo,
  });

  /// Confirma y bloquea el peritaje (pasa a `Peritaje_Validado`).
  Future<Siniestro> confirmarPeritaje(String siniestroId);

  /// Obtiene el perfil del ajustador autenticado.
  Future<PerfilAjustador> obtenerPerfil();
}
