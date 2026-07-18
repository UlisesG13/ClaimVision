import 'package:go_router/go_router.dart';

import '../../../core/routes/route_paths.dart';
import 'pages/document_type_page.dart';

List<GoRoute> ocrRoutes = [
  GoRoute(
    path: RoutePaths.capturaDocumentos,
    builder: (_, _) => const DocumentTypePage(),
  ),
];
