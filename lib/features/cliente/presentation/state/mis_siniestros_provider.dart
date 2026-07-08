import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:claimvision/shared/domain/entities/siniestro.dart';
import '../../../../core/di/providers.dart';

class MisSiniestros extends AsyncNotifier<List<Siniestro>> {
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

final misSiniestrosProvider =
    AsyncNotifierProvider<MisSiniestros, List<Siniestro>>(MisSiniestros.new);
