import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

/// Casos (siniestros) asignados al ajustador — flujo async con red → Riverpod.
/// Maneja los estados cargando / éxito / vacío / error vía [AsyncValue].
class CasosAsignadosController extends AsyncNotifier<List<Siniestro>> {
  @override
  Future<List<Siniestro>> build() async {
    return ref.read(getCasosAsignadosProvider)();
  }

  /// Recarga la bandeja (pull-to-refresh / reintento).
  Future<void> refrescar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(getCasosAsignadosProvider)());
  }
}

final casosAsignadosControllerProvider =
    AsyncNotifierProvider<CasosAsignadosController, List<Siniestro>>(
        CasosAsignadosController.new);
