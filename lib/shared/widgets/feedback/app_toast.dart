import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tipo visual del toast.
enum ToastKind { success, error, info }

/// Toasts flotantes de ClaimVision: avisos breves que aparecen sobre el
/// contenido y desaparecen solos. Implementados con `Overlay` (Flutter no tiene
/// toast nativo), sin dependencias externas.
///
/// Uso: `AppToast.success(context, 'Guardado correctamente');`
class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    String message, {
    ToastKind kind = ToastKind.info,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        kind: kind,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.success);
  static void error(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.error);
  static void info(BuildContext context, String message) =>
      show(context, message, kind: ToastKind.info);
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.kind,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final ToastKind kind;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, _cerrar);
  }

  Future<void> _cerrar() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (widget.kind) {
      ToastKind.success => (Icons.check_circle, AppColors.success),
      ToastKind.error => (Icons.error_outline, AppColors.alert),
      ToastKind.info => (Icons.notifications_none, AppColors.blueprint),
    };

    return Positioned(
      left: AppSpacing.xl,
      right: AppSpacing.xl,
      bottom: MediaQuery.of(context).viewInsets.bottom + 90,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_fade),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueprint.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20, color: color),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(widget.message,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
