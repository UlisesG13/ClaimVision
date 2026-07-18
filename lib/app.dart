import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_router.dart';
import 'core/security/domain/entities/security_status.dart';
import 'core/security/presentation/pages/blocked_page.dart';
import 'core/security/presentation/providers/security_providers.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/widgets/in_app_banner.dart';

class ClaimVisionApp extends ConsumerStatefulWidget {
  const ClaimVisionApp({super.key});

  @override
  ConsumerState<ClaimVisionApp> createState() => _ClaimVisionAppState();
}

class _ClaimVisionAppState extends ConsumerState<ClaimVisionApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.onForegroundMessage = (RemoteMessage message) {
      ref.read(currentNotificationProvider.notifier).show(message);
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(securityControllerProvider.notifier).recheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return security.when(
      loading: () => _splashApp(themeMode),
      error: (_, _) => _normalApp(themeMode, ref),
      data: (status) {
        if (status is SecurityCompromised) {
          return _blockedApp(themeMode, status);
        }
        return _normalApp(themeMode, ref);
      },
    );
  }
}

Widget _splashApp(ThemeMode themeMode) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: const _Splash(),
  );
}

Widget _blockedApp(ThemeMode themeMode, SecurityCompromised status) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    home: BlockedPage(issues: status.issues),
  );
}

Widget _normalApp(ThemeMode themeMode, WidgetRef ref) {
  final router = ref.watch(routerProvider);
  return MaterialApp.router(
    title: 'ClaimVision',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    routerConfig: router,
    builder: (context, child) {
      return Stack(
        children: [
          child!,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: InAppBanner(),
          ),
        ],
      );
    },
  );
}

class _Splash extends StatelessWidget {
  const _Splash();

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
