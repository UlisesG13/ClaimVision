import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/siniestro.dart';

/// Store en memoria de los siniestros del cliente durante la sesión.
///
/// El backend aún no expone un endpoint para LISTAR los siniestros del cliente
/// (solo crear/actualizar), por lo que el dashboard se alimenta de los
/// siniestros que el cliente crea en esta sesión. Cuando el backend agregue un
/// `GET /siniestros` del cliente, este store se reemplaza por un
/// `FutureProvider`/`AsyncNotifier` que lo consuma.
class MisSiniestros extends Notifier<List<Siniestro>> {
  @override
  List<Siniestro> build() => const [];

  /// Agrega un siniestro recién creado al inicio de la lista.
  void agregar(Siniestro siniestro) {
    state = [siniestro, ...state];
  }

  /// Reemplaza un siniestro existente (por id) tras una actualización.
  void actualizar(Siniestro siniestro) {
    state = [
      for (final s in state)
        if (s.id == siniestro.id) siniestro else s,
    ];
  }

  int get activos => state.where((s) => s.estatus.enProceso).length;
  int get total => state.length;
}

final misSiniestrosProvider =
    NotifierProvider<MisSiniestros, List<Siniestro>>(MisSiniestros.new);
