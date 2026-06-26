import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../theme/app_colors.dart';
import 'route_paths.dart';

/// Router de la app con guard de acceso por sesión.
///
/// Observa `authControllerProvider`: redirige según haya o no sesión, y manda
/// a cada rol a su inicio. Mientras se restaura la sesión guardada, muestra un
/// splash para no parpadear hacia el login.
final routerProvider = Provider<GoRouter>((ref) {
  // Notificador que fuerza al GoRouter a reevaluar `redirect` cada vez que
  // cambia el estado de autenticación.
  final refresh = _AuthRefreshNotifier();
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, _) => refresh.bump());

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      // Aún restaurando la sesión inicial → quedarse en el splash (solo al
      // arrancar; un login/registro posterior no vuelve a pasar por aquí).
      if (ref.read(authControllerProvider.notifier).isRestoring) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      final AuthSession? session = auth.asData?.value;
      final isAuthed = session != null;
      final authScreens = {RoutePaths.login, RoutePaths.register};

      if (!isAuthed) {
        // Sin sesión: solo se permiten las pantallas de acceso.
        return authScreens.contains(location) ? null : RoutePaths.login;
      }

      // Con sesión: salir del splash o de un login traspapelado hacia el inicio.
      // El registro navega por su cuenta al onboarding, así que aquí se permite.
      if (location == RoutePaths.splash || location == RoutePaths.login) {
        return _homeFor(session);
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, _) => const _SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: RoutePaths.inicio,
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.perfil,
        builder: (_, _) => const ProfilePage(),
      ),
    ],
  );
});

/// Devuelve la ruta de inicio según el rol del usuario.
String _homeFor(AuthSession session) {
  // Por ahora el flujo móvil del Cliente entra a su inicio. Otros roles se
  // enrutarán a su propio dashboard cuando se implementen.
  return RoutePaths.inicio;
}

/// ChangeNotifier mínimo para refrescar el router ante cambios de auth.
class _AuthRefreshNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}

/// Splash mostrado mientras se restaura la sesión persistida.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.blueprint,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.amber),
      ),
    );
  }
}
