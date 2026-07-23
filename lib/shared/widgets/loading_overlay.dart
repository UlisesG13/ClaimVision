import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Indicador de carga **inline** (spinner + mensaje) para usar dentro del flujo
/// normal de un `Column`/tarjeta. A diferencia de [LoadingOverlay], no dibuja
/// ningún velo de pantalla completa — úsalo cuando la carga es local a una
/// sección y no debe bloquear/oscurecer toda la pantalla.
class InlineLoading extends StatelessWidget {
  const InlineLoading({super.key, this.message, this.color});

  final String? message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.blueprint;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: c),
          ),
          if (message != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message,
    this.opacity = 0.6,
  });

  final String? message;
  final double opacity;

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => LoadingOverlay(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.black.withValues(alpha: opacity),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.blueprint),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
