import 'package:claimvision/shared/domain/entities/siniestro.dart';

import '../entities/damage_adjusted.dart';
import '../entities/perfil_ajustador.dart';
import '../entities/peritaje.dart';

abstract interface class PeritajeRepository {
  Future<List<Siniestro>> getCasosAsignados({int page = 1, int pageSize = 20, String? estatus});

  Future<Peritaje> registrarPeritaje({
    required String siniestroId,
    required double costoDefinitivo,
    required String firmaDigitalBase64,
    required List<DamageAdjusted> danos,
    String? observacionesCampo,
  });

  Future<Siniestro> obtenerDetalleSiniestro(String id);

  Future<PerfilAjustador> obtenerPerfil();
}
