import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../pages/client_home_page.dart';
import '../pages/historial_page.dart';
import '../pages/notificaciones_page.dart';
import '../pages/report_analysis_page.dart';
import '../pages/report_damage_page.dart';
import '../pages/report_location_page.dart';
import '../pages/report_narration_page.dart';
import '../pages/report_vehicle_page.dart';
import '../pages/siniestro_detail_page.dart';
import '../pages/vehiculos_page.dart';

List<GoRoute> clienteRoutes = [
  GoRoute(
    path: RoutePaths.inicio,
    builder: (_, _) => const ClientHomePage(),
  ),
  GoRoute(
    path: RoutePaths.historial,
    builder: (_, _) => const HistorialPage(),
  ),
  GoRoute(
    path: RoutePaths.vehiculos,
    builder: (_, _) => const VehiculosPage(),
  ),
  GoRoute(
    path: RoutePaths.reportar,
    builder: (_, _) => const ReportVehiclePage(),
  ),
  GoRoute(
    path: RoutePaths.reportarUbicacion,
    builder: (_, _) => const ReportLocationPage(),
  ),
  GoRoute(
    path: RoutePaths.reportarNarracion,
    builder: (_, _) => const ReportNarrationPage(),
  ),
  GoRoute(
    path: RoutePaths.reportarDano,
    builder: (_, _) => const ReportDamagePage(),
  ),
  GoRoute(
    path: RoutePaths.reportarAnalisis,
    builder: (_, _) => const ReportAnalysisPage(),
  ),
  GoRoute(
    path: RoutePaths.notificaciones,
    builder: (_, _) => const NotificacionesPage(),
  ),
  GoRoute(
    path: RoutePaths.detalleSiniestro,
    builder: (_, state) => SiniestroDetailPage(
      siniestroId: state.pathParameters['id'] ?? '',
    ),
  ),
];
