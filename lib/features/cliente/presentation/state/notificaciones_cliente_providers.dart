import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:claimvision/shared/state/notificaciones_controller.dart';
import 'mis_siniestros_controller.dart';

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

/// Notificaciones del cliente derivadas de SUS siniestros.
///
/// Se alimenta de [misSiniestrosControllerProvider] (que obtiene la lista desde la API).
/// Mientras el backend no exponga un endpoint de notificaciones, generamos
/// notificaciones reales a partir de los siniestros del cliente.
final notificacionesProvider = Provider<List<Notificacion>>((ref) {
  final siniestrosAsync = ref.watch(misSiniestrosControllerProvider);
  final siniestros = siniestrosAsync.asData?.value ?? const [];
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
