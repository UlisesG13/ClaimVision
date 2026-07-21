import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'providers.dart';

class MisSiniestrosController extends AsyncNotifier<List<Siniestro>> {
  @override
  Future<List<Siniestro>> build() async {
    final getSiniestros = ref.read(getSiniestrosClienteProvider);
    return getSiniestros();
  }

  Future<void> refrescar() async {
    ref.invalidateSelf();
  }

  int get activos {
    final data = state.asData?.value ?? const [];
    return data.where((s) => s.estatus.enProceso).length;
  }

  int get total {
    return state.asData?.value.length ?? 0;
  }
}

final misSiniestrosControllerProvider =
    AsyncNotifierProvider<MisSiniestrosController, List<Siniestro>>(MisSiniestrosController.new);
