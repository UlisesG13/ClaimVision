import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

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
                    size: 80,
                    color: AppColors.white.withValues(alpha: 0.3),
                  ),
                  const Gap(AppSpacing.lg),
                  Text(
                    'Escanea tu póliza',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close, color: AppColors.white),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Saltar',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Coloca tu póliza dentro del marco',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge,
                      ),
                      const Gap(AppSpacing.sm),
                      Text(
                        'Asegúrate de que el código QR y la información sean visibles',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Gap(AppSpacing.xl),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Escanear ahora'),
                      ),
                      const Gap(AppSpacing.md),
                      SizedBox(
                        height: 44,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Subir imagen manualmente',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
