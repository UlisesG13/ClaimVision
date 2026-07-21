import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56, this.glow = false});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + AppSpacing.lg,
      height: size + AppSpacing.lg,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        width: size,
        height: size,
      ),
    );
  }
}
