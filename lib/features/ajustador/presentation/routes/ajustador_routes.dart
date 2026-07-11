import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../pages/casos_asignados_page.dart';
import '../pages/caso_detalle_page.dart';
import '../pages/firma_peritaje_page.dart';
import '../pages/notificaciones_ajustador_page.dart';
import '../pages/peritaje_confirmado_page.dart';
import '../pages/validacion_peritaje_page.dart';

List<GoRoute> ajustadorRoutes = [
  GoRoute(
    path: RoutePaths.casos,
    builder: (_, _) => const CasosAsignadosPage(),
  ),
  GoRoute(
    path: RoutePaths.casoDetalle,
    builder: (_, state) =>
        CasoDetallePage(siniestroId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: RoutePaths.validacionPeritaje,
    builder: (_, state) => ValidacionPeritajePage(
        siniestroId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: RoutePaths.firmaPeritaje,
    builder: (_, state) =>
        FirmaPeritajePage(siniestroId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: RoutePaths.peritajeConfirmado,
    builder: (_, state) => PeritajeConfirmadoPage(
        siniestroId: state.pathParameters['id'] ?? ''),
  ),
  GoRoute(
    path: RoutePaths.notificacionesAjustador,
    builder: (_, _) => const NotificacionesAjustadorPage(),
  ),
];
