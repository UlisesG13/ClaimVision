import 'package:go_router/go_router.dart';

import '../../../../core/constants/legal_texts.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../shared/pages/legal_document_page.dart';
import '../pages/login_page.dart';
import '../pages/onboarding_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

List<GoRoute> authRoutes = [
  GoRoute(
    path: RoutePaths.login,
    builder: (_, _) => const LoginPage(),
  ),
  GoRoute(
    path: RoutePaths.onboarding,
    builder: (_, _) => const OnboardingPage(),
  ),
  GoRoute(
    path: RoutePaths.perfil,
    builder: (_, _) => const ProfilePage(),
  ),
  GoRoute(
    path: RoutePaths.configuracion,
    builder: (_, _) => const SettingsPage(),
  ),
  GoRoute(
    path: RoutePaths.avisoPrivacidad,
    builder: (_, _) => const LegalDocumentPage(
      titulo: 'Aviso de Privacidad',
      contenido: LegalTexts.avisoPrivacidad,
    ),
  ),
  GoRoute(
    path: RoutePaths.terminos,
    builder: (_, _) => const LegalDocumentPage(
      titulo: 'Términos y Condiciones',
      contenido: LegalTexts.terminosCondiciones,
    ),
  ),
];
