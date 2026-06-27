import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/siniestro.dart';
import 'mis_siniestros_provider.dart';

/// Tipo de notificación (la UI lo mapea a un ícono/color).
enum NotificacionTipo { reporte, estado }

/// Notificación mostrada al cliente. Modelo de presentación.
class Notificacion {
  const Notificacion({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.fecha,
    required this.tipo,
    required this.leida,
  });

  final String id;
  final String titulo;
  final String cuerpo;
  final DateTime fecha;
  final NotificacionTipo tipo;
  final bool leida;
}

/// Conjunto de ids de notificaciones marcadas como leídas (estado local).
class NotificacionesLeidas extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void marcarLeidas(Iterable<String> ids) {
    state = {...state, ...ids};
  }

  void marcarLeida(String id) {
    state = {...state, id};
  }
}

final notificacionesLeidasProvider =
    NotifierProvider<NotificacionesLeidas, Set<String>>(
        NotificacionesLeidas.new);

/// Notificaciones del cliente derivadas de SUS siniestros de la sesión.
///
/// El backend no expone un listado de notificaciones (solo push para órdenes de
/// entrega). Mientras tanto, generamos notificaciones reales a partir de los
/// siniestros reportados en la sesión ([misSiniestrosProvider]); cuando exista
/// un endpoint, este provider se reemplaza por uno que lo consuma.
final notificacionesProvider = Provider<List<Notificacion>>((ref) {
  final siniestros = ref.watch(misSiniestrosProvider);
  final leidas = ref.watch(notificacionesLeidasProvider);

  final lista = <Notificacion>[
    for (final Siniestro s in siniestros)
      Notificacion(
        id: 'rep_${s.id}',
        titulo: 'Reporte enviado',
        cuerpo:
            'Tu siniestro ${s.folioCorto} (${s.vehiculoResumen}) fue enviado a tu aseguradora.',
        fecha: s.createdAt,
        tipo: NotificacionTipo.reporte,
        leida: leidas.contains('rep_${s.id}'),
      ),
  ];

  lista.sort((a, b) => b.fecha.compareTo(a.fecha));
  return lista;
});

/// Cantidad de notificaciones sin leer (para el badge de la campana).
final notificacionesNoLeidasProvider = Provider<int>((ref) {
  return ref.watch(notificacionesProvider).where((n) => !n.leida).length;
});
