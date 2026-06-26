import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/claim_vision_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ClaimVision',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.blueprint,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: AppColors.blueprint),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingSection(),
            const Gap(AppSpacing.xl),
            PolicyCard(),
            const Gap(AppSpacing.xl),
            PrimaryActionButton(),
            const Gap(AppSpacing.xl),
            RecentActivitySection(),
          ],
        ),
      ),
      bottomNavigationBar: ClaimVisionBottomNav(currentIndex: 0),
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¡Buenos días!', style: theme.textTheme.displayMedium),
        const Gap(AppSpacing.xs),
        Text(
          'Juan Pérez',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class PolicyCard extends StatelessWidget {
  const PolicyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blueprint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueprint.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.amber),
              const Gap(AppSpacing.sm),
              Text(
                'Póliza de Auto',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Text(
            'Póliza #CV-2024-001234',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.white,
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            'Vigente hasta: 31/12/2025',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const Gap(AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PolicyStat(label: 'Cobertura', value: 'Amplia'),
              _PolicyStat(label: 'Deducible', value: '\$2,000'),
              _PolicyStat(label: 'Estado', value: 'Activa'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicyStat extends StatelessWidget {
  final String label;
  final String value;

  const _PolicyStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.5),
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Reportar un siniestro'),
      ),
    );
  }
}

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  final List<Map<String, String>> activities = const [
    {
      'title': 'Siniestro #CV-2024-089',
      'subtitle': 'Actualizado — En revisión',
      'date': '15/01/2024',
    },
    {
      'title': 'Siniestro #CV-2024-076',
      'subtitle': 'Completado — Indemnizado',
      'date': '10/01/2024',
    },
    {
      'title': 'Siniestro #CV-2024-054',
      'subtitle': 'Documentos requeridos',
      'date': '28/12/2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actividad reciente', style: theme.textTheme.headlineLarge),
        const Gap(AppSpacing.md),
        ...activities.map(
          (a) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppColors.blueprint,
                    size: 20,
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['title']!,
                        style: theme.textTheme.labelLarge,
                      ),
                      const Gap(2),
                      Text(
                        a['subtitle']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  a['date']!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
