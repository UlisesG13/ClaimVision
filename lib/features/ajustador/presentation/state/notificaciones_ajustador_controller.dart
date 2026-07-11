import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ids de notificaciones del ajustador marcadas como leídas (estado local).
/// El backend no expone un listado de notificaciones; se derivan de los casos
/// asignados ([casosAsignadosControllerProvider]).
class NotificacionesAjustadorController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void marcarLeidas(Iterable<String> ids) => state = {...state, ...ids};
  void marcarLeida(String id) => state = {...state, id};
}

final notificacionesAjustadorControllerProvider =
    NotifierProvider<NotificacionesAjustadorController, Set<String>>(
        NotificacionesAjustadorController.new);
