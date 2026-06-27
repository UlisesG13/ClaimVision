import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:claimvision/shared/domain/entities/siniestro_estatus.dart';

/// Tarjeta de un siniestro (folio, estatus, vehículo, fecha). Reutilizada en el
/// dashboard y en el historial.
class SiniestroCard extends StatelessWidget {
  const SiniestroCard({super.key, required this.siniestro, required this.onTap});

  final Siniestro siniestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Siniestro ${siniestro.folioCorto}',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                SiniestroEstatusChip(estatus: siniestro.estatus),
              ],
            ),
            const Gap(AppSpacing.md),
            _IconLine(
                icon: Icons.directions_car_outlined,
                text: siniestro.vehiculoResumen),
            const Gap(AppSpacing.xs),
            _IconLine(
                icon: Icons.schedule,
                text: DateFormatEs.fechaHora(siniestro.fechaSiniestro)),
          ],
        ),
      ),
    );
  }
}

/// Chip de color según el estatus del siniestro.
class SiniestroEstatusChip extends StatelessWidget {
  const SiniestroEstatusChip({super.key, required this.estatus});
  final SiniestroEstatus estatus;

  @override
  Widget build(BuildContext context) {
    final color = switch (estatus.tono) {
      SiniestroEstatusTono.neutro => AppColors.textSecondary,
      SiniestroEstatusTono.proceso => AppColors.amber,
      SiniestroEstatusTono.info => AppColors.blueprint,
      SiniestroEstatusTono.exito => AppColors.success,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(estatus.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              )),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
