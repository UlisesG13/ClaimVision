import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class DamageCapturePage extends StatelessWidget {
  const DamageCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColors.blueprint,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 60,
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    'Captura de daño',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusXl),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toma una foto del daño',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const Gap(AppSpacing.xs),
                      Text(
                        'Enfoca bien el área afectada y asegúrate de que haya buena iluminación',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _PhotoSlot(
                              icon: Icons.directions_car_outlined,
                              label: 'Vista general',
                            ),
                          ),
                          const Gap(AppSpacing.md),
                          Expanded(
                            child: _PhotoSlot(
                              icon: Icons.zoom_in_outlined,
                              label: 'Primer plano',
                            ),
                          ),
                          const Gap(AppSpacing.md),
                          Expanded(
                            child: _PhotoSlot(
                              icon: Icons.swap_horiz_outlined,
                              label: 'Lateral',
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Tomar foto'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PhotoSlot({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.blueprint.withValues(alpha: 0.1),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.blueprint.withValues(alpha: 0.3),
            size: 28,
          ),
          const Gap(AppSpacing.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
