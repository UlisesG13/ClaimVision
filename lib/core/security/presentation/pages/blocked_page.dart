import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/security_status.dart';

class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key, required this.issues});
  final List<SecurityIssue> issues;

  String get _titulo {
    if (issues.contains(SecurityIssue.emulator)) {
      return 'No disponible en emuladores';
    }
    return 'Dispositivo no seguro';
  }

  String get _descripcion {
    if (issues.contains(SecurityIssue.emulator)) {
      return 'Esta aplicación no puede ejecutarse en un emulador. Usa un dispositivo físico para continuar.';
    }
    return 'Se detectaron configuraciones de seguridad no permitidas. Corrígelas para acceder a la aplicación.';
  }

  String _mensajeIssue(SecurityIssue issue) {
    return switch (issue) {
      SecurityIssue.developerOptions => 'Opciones de desarrollador activadas',
      SecurityIssue.adbEnabled => 'Depuración USB (ADB) activada',
      SecurityIssue.appDebuggable => 'La aplicación está en modo debug',
      SecurityIssue.mockLocation => 'Ubicación simulada (Fake GPS) activada',
      SecurityIssue.emulator => 'Emulador detectado',
    };
  }

  IconData _iconoIssue(SecurityIssue issue) {
    return switch (issue) {
      SecurityIssue.developerOptions => Icons.developer_mode,
      SecurityIssue.adbEnabled => Icons.usb,
      SecurityIssue.appDebuggable => Icons.bug_report,
      SecurityIssue.mockLocation => Icons.location_off,
      SecurityIssue.emulator => Icons.phone_android,
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.blueprint,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 80, color: AppColors.amber),
                  const SizedBox(height: 24),
                  Text(
                    _titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _descripcion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...issues.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(_iconoIssue(issue), color: AppColors.amber, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _mensajeIssue(issue),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => SystemNavigator.pop(),
                      icon: const Icon(Icons.exit_to_app, size: 20),
                      label: const Text('Cerrar aplicación'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alert,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
