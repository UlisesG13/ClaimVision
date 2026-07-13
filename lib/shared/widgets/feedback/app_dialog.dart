import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Diálogos de ClaimVision (sobre `showDialog`/`AlertDialog`). Centraliza el
/// estilo y la copia de las alertas de la app.
class AppDialog {
  AppDialog._();

  /// Confirmación. Devuelve `true` si el usuario confirma. Usa [danger] para
  /// acciones destructivas (botón en rojo).
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
    String cancelLabel = 'Cancelar',
    bool danger = false,
    IconData? icon,
  }) async {
    final theme = Theme.of(context);
    final accent = danger ? AppColors.alert : AppColors.blueprint;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: icon != null ? Icon(icon, color: accent, size: 32) : null,
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: accent),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  /// Aviso informativo de un solo botón (éxito / información).
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String okLabel = 'Entendido',
    IconData icon = Icons.check_circle,
    Color accent = AppColors.success,
  }) {
    final theme = Theme.of(context);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, color: accent, size: 36),
        title: Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
        content: Text(message,
            textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: accent),
            child: Text(okLabel),
          ),
        ],
      ),
    );
  }

  /// Error con opción de reintentar. Devuelve `true` si el usuario pulsa
  /// reintentar.
  static Future<bool> retry(
    BuildContext context, {
    required String title,
    required String message,
    String retryLabel = 'Reintentar',
    String cancelLabel = 'Cerrar',
  }) async {
    final theme = Theme.of(context);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: AppColors.alert, size: 32),
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
            child: Text(retryLabel),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  /// Solicitud de permiso (cámara / ubicación). Devuelve `true` si el usuario
  /// acepta.
  static Future<bool> permission(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String allowLabel = 'Permitir',
    String denyLabel = 'Ahora no',
  }) async {
    final theme = Theme.of(context);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, color: AppColors.blueprint, size: 32),
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(denyLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
            child: Text(allowLabel),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  /// Diálogo de carga con barrera (no descartable). Cerrar con [hideLoading].
  static void showLoading(BuildContext context,
      {String title = 'Procesando…', String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: ctx.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.amber),
                const Gap(AppSpacing.lg),
                Text(title,
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.titleMedium),
                if (message != null) ...[
                  const Gap(AppSpacing.xs),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: Theme.of(ctx).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Cierra el diálogo de carga abierto con [showLoading].
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
