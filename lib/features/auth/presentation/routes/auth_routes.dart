import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../pages/login_page.dart';
import '../pages/onboarding_page.dart';
import '../pages/profile_page.dart';

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
];
