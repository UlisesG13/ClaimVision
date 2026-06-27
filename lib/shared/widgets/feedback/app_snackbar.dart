import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tipo visual del snackbar (define el ícono y el color del acento).
enum SnackKind { neutral, success, error, warning, info }

/// Snackbars de ClaimVision (Material 3, fondo `inverseSurface`, acción a la
/// derecha). Centraliza el estilo de los avisos breves de la app.
///
/// Uso:
/// ```dart
/// AppSnackbar.success(context, 'Peritaje confirmado');
/// AppSnackbar.error(context, 'Error de conexión',
///     actionLabel: 'REINTENTAR', onAction: _retry);
/// AppSnackbar.show(context, 'Fotos subidas',
///     detail: '3 imágenes adjuntadas', actionLabel: 'VER', onAction: ...);
/// ```
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    String? detail,
    String? actionLabel,
    VoidCallback? onAction,
    SnackKind kind = SnackKind.neutral,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onInverseSurface;
    final acento = _acento(kind);
    final icon = _icono(kind);

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: theme.colorScheme.inverseSurface,
          duration: duration,
          margin: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: acento ?? onSurface),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: onSurface)),
                    if (detail != null)
                      Text(detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withValues(alpha: 0.7),
                          )),
                  ],
                ),
              ),
            ],
          ),
          action: (actionLabel != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: AppColors.amber,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }

  static void success(BuildContext context, String message,
          {String? detail, String? actionLabel, VoidCallback? onAction}) =>
      show(context, message,
          detail: detail,
          actionLabel: actionLabel,
          onAction: onAction,
          kind: SnackKind.success);

  static void error(BuildContext context, String message,
          {String? detail, String? actionLabel, VoidCallback? onAction}) =>
      show(context, message,
          detail: detail,
          actionLabel: actionLabel,
          onAction: onAction,
          kind: SnackKind.error);

  static void warning(BuildContext context, String message,
          {String? detail, String? actionLabel, VoidCallback? onAction}) =>
      show(context, message,
          detail: detail,
          actionLabel: actionLabel,
          onAction: onAction,
          kind: SnackKind.warning);

  static Color? _acento(SnackKind kind) => switch (kind) {
        SnackKind.success => AppColors.success,
        SnackKind.error => AppColors.alert,
        SnackKind.warning => AppColors.amber,
        SnackKind.info => AppColors.amber,
        SnackKind.neutral => null,
      };

  static IconData? _icono(SnackKind kind) => switch (kind) {
        SnackKind.success => Icons.check_circle,
        SnackKind.error => Icons.error_outline,
        SnackKind.warning => Icons.warning_amber_rounded,
        SnackKind.info => Icons.info_outline,
        SnackKind.neutral => null,
      };
}
