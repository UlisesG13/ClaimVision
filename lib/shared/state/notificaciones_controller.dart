import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado inmutable de notificaciones leídas (ids).
class NotificacionesState {
  const NotificacionesState({this.leidas = const {}});

  final Set<String> leidas;

  NotificacionesState copyWith({Set<String>? leidas}) {
    return NotificacionesState(leidas: leidas ?? this.leidas);
  }
}

/// Controller unificado de notificaciones para cliente y ajustador.
///
/// Mantiene un [Set] de ids marcados como leídos en memoria.
/// Cada feature deriva sus propias notificaciones desde sus siniestros/casos
/// y usa este controller solo para el estado de "leído".
class NotificacionesController extends Notifier<NotificacionesState> {
  @override
  NotificacionesState build() => const NotificacionesState();

  void marcarLeidas(Iterable<String> ids) {
    state = state.copyWith(leidas: {...state.leidas, ...ids});
  }

  void marcarLeida(String id) {
    state = state.copyWith(leidas: {...state.leidas, id});
  }
}

final notificacionesControllerProvider =
    NotifierProvider<NotificacionesController, NotificacionesState>(
        NotificacionesController.new);

/// Provider auxiliar para obtener solo el Set de leídas (más eficiente que watch state).
final notificacionesLeidasProvider = Provider<Set<String>>((ref) {
  return ref.watch(notificacionesControllerProvider).leidas;
});
