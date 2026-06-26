import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Encabezado de los pasos del wizard de reporte (#5–#8): botón atrás, título,
/// subtítulo "Paso X de N · …" e indicador de progreso por segmentos.
class ReportStepHeader extends StatelessWidget {
  const ReportStepHeader({
    super.key,
    required this.subtitulo,
    required this.pasoActual,
    required this.totalPasos,
    required this.onBack,
  });

  final String subtitulo;
  final int pasoActual; // 1-based
  final int totalPasos;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.arrow_back,
                  size: 20, color: AppColors.textPrimary),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reportar Incidente', style: theme.textTheme.titleLarge),
                Text('Paso $pasoActual de $totalPasos · $subtitulo',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Row(
            children: List.generate(totalPasos, (i) {
              final activo = i < pasoActual;
              return Container(
                width: 18,
                height: 5,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: activo ? AppColors.amber : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
