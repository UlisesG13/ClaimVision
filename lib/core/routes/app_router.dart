import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/ajustador/presentation/routes/ajustador_routes.dart';
import '../../features/auth/presentation/routes/auth_routes.dart';
import '../../features/cliente/presentation/routes/cliente_routes.dart';
import '../security/domain/entities/security_status.dart';
import '../security/presentation/pages/blocked_page.dart';
import '../security/presentation/providers/security_providers.dart';
import '../services/notification_payload.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'route_paths.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier();
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, _) => refresh.bump());

  final router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;

      final security = ref.read(securityControllerProvider);
      final status = security.asData?.value;
      if (status is SecurityCompromised && location != RoutePaths.bloqueado) {
        return RoutePaths.bloqueado;
      }
      if (location == RoutePaths.bloqueado) return null;

      final auth = ref.read(authControllerProvider);

      if (ref.read(authControllerProvider.notifier).isRestoring) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      final AuthSession? session = auth.asData?.value;
      final isAuthed = session != null;
      final authScreens = {RoutePaths.login};

      if (!isAuthed) {
        return authScreens.contains(location) ? null : RoutePaths.login;
      }

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
        path: RoutePaths.bloqueado,
        builder: (_, _) => Consumer(
          builder: (context, ref, _) {
            final status = ref.watch(securityControllerProvider).asData?.value;
            final issues = status is SecurityCompromised
                ? status.issues
                : <SecurityIssue>[];
            return BlockedPage(issues: issues);
          },
        ),
      ),
      ...authRoutes,
      ...clienteRoutes,
      ...ajustadorRoutes,
    ],
  );

  // ── Notificaciones push ──────────────────────────────────────────────

  void navigateByNotification(
    NotificationPayload payload,
    AuthSession session,
  ) {
    final route = switch ((session.rol, payload.type)) {
      (UserRole.ajustador, 'asignacion') when payload.id != null
          => RoutePaths.casoDetalleDe(payload.id!),
      (UserRole.cliente, 'siniestro') when payload.id != null
          => RoutePaths.detalleSiniestroDe(payload.id!),
      (UserRole.ajustador, 'notificacion')
          => RoutePaths.notificacionesAjustador,
      (_, 'notificacion') => RoutePaths.notificaciones,
      _ => _homeFor(session),
    };
    router.go(route);
  }

  void handleNotificationPayload(NotificationPayload payload) {
    final session = ref.read(authControllerProvider).asData?.value;
    if (session != null) {
      navigateByNotification(payload, session);
    } else {
      NotificationService.pendingNavigationPayload = payload;
    }
  }

  void handleRemoteMessage(RemoteMessage message) {
    handleNotificationPayload(NotificationPayload.fromMessage(message));
  }

  // Abierta desde background
  NotificationService.instance.onMessageOpenedApp = handleRemoteMessage;

  // Tap en notificación local (foreground)
  NotificationService.instance.onNotificationTap =
      handleNotificationPayload;

  // Pendiente por sesión no restaurada aún
  ref.listen(authControllerProvider, (prev, next) {
    final wasLoading = prev?.isLoading ?? true;
    final session = next.asData?.value;
    if (wasLoading && session != null) {
      final pending = NotificationService.pendingNavigationPayload;
      if (pending != null) {
        NotificationService.pendingNavigationPayload = null;
        navigateByNotification(pending, session);
      }
    }
  });

  return router;
});

String _homeFor(AuthSession session) {
  return switch (session.rol) {
    UserRole.ajustador => RoutePaths.casos,
    _ => RoutePaths.inicio,
  };
}

class _AuthRefreshNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueprint,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amber.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 68,
                    height: 68,
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.xl),
            FadeTransition(
              opacity: _fade,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.amber,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
