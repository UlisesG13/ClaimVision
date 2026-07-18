import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/document_type.dart';
import '../../domain/image_quality.dart';

class ValidationIndicator extends StatelessWidget {
  const ValidationIndicator({
    super.key,
    required this.quality,
    required this.type,
  });

  final ImageQuality quality;
  final DocumentType type;

  @override
  Widget build(BuildContext context) {
    final errors = quality.checkErrors(
      type.minWidth,
      type.minHeight,
      type.sharpnessThreshold,
      type.brightnessMin,
      type.brightnessMax,
    );

    final isValid = errors.isEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isValid
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.alert.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isValid
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.alert.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _line(
            isValid ? Icons.check_circle : Icons.error,
            isValid ? AppColors.success : AppColors.alert,
            isValid
                ? 'Imagen válida'
                : 'Corrige antes de continuar',
          ),
          if (!isValid) ...[
            const Gap(AppSpacing.sm),
            ...errors.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _line(Icons.close, AppColors.alert, e),
            )),
          ],
          const Gap(AppSpacing.xs),
          _line(Icons.info_outline, AppColors.textHint,
              '${quality.width}x${quality.height} · '
              'Nitidez: ${quality.sharpness.toStringAsFixed(0)} · '
              'Brillo: ${quality.brightness.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _line(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: color)),
        ),
      ],
    );
  }
}
