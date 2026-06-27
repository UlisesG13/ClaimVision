import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tono del banner en línea.
enum InlineBannerKind { info, security, warning, error }

/// Banner informativo en línea (se incrusta dentro del contenido de una
/// pantalla, no en la parte superior como el MaterialBanner). Ícono + título +
/// mensaje, con acción opcional (chevron).
///
/// Uso:
/// ```dart
/// InlineBanner(
///   kind: InlineBannerKind.security,
///   title: 'Datos cifrados',
///   message: 'Tu información se protege con AES-256-GCM.',
/// )
/// ```
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.title,
    required this.message,
    this.kind = InlineBannerKind.info,
    this.icon,
    this.onTap,
  });

  final String title;
  final String message;
  final InlineBannerKind kind;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _color(kind);
    final iconData = icon ?? _icono(kind);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 20, color: color),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: AppColors.textPrimary)),
                    const Gap(2),
                    Text(message,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const Gap(AppSpacing.sm),
                Icon(Icons.chevron_right, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _color(InlineBannerKind kind) => switch (kind) {
        InlineBannerKind.info => AppColors.blueprint,
        InlineBannerKind.security => AppColors.success,
        InlineBannerKind.warning => AppColors.amber,
        InlineBannerKind.error => AppColors.alert,
      };

  static IconData _icono(InlineBannerKind kind) => switch (kind) {
        InlineBannerKind.info => Icons.info_outline,
        InlineBannerKind.security => Icons.shield_outlined,
        InlineBannerKind.warning => Icons.schedule,
        InlineBannerKind.error => Icons.wifi_off,
      };
}
