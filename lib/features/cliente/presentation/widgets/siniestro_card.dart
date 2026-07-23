import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/app_card.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:claimvision/shared/domain/entities/siniestro_status.dart';

/// Tarjeta de un siniestro (folio, estatus, vehículo, fecha). Reutilizada en el
/// dashboard y en el historial.
class SiniestroCard extends StatelessWidget {
  const SiniestroCard({super.key, required this.siniestro, required this.onTap});

  final Siniestro siniestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = switch (siniestro.estatus.tono) {
      SiniestroStatusTono.neutro => null,
      SiniestroStatusTono.proceso => AppColors.amber,
      SiniestroStatusTono.info => AppColors.blueprint,
      SiniestroStatusTono.exito => AppColors.success,
    };
    return AppCard(
      onTap: onTap,
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Siniestro ${siniestro.folioCorto}',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const Gap(AppSpacing.sm),
              SiniestroStatusChip(estatus: siniestro.estatus),
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
    );
  }
}

/// Chip de color según el estatus del siniestro.
class SiniestroStatusChip extends StatelessWidget {
  const SiniestroStatusChip({super.key, required this.estatus});
  final SiniestroStatus estatus;

  @override
  Widget build(BuildContext context) {
    final color = switch (estatus.tono) {
      SiniestroStatusTono.neutro => context.textSecondaryColor,
      SiniestroStatusTono.proceso => AppColors.amber,
      SiniestroStatusTono.info => AppColors.blueprint,
      SiniestroStatusTono.exito => AppColors.success,
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
        Icon(icon, size: 16, color: context.textSecondaryColor),
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
