import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../cliente/presentation/widgets/siniestro_card.dart';

/// Tarjeta de un caso asignado en la bandeja del ajustador.
class CasoCard extends StatelessWidget {
  const CasoCard({super.key, required this.siniestro, required this.onValidar});

  final Siniestro siniestro;
  final VoidCallback onValidar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(siniestro.folioCorto,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16)),
              SiniestroStatusChip(estatus: siniestro.estatus),
            ],
          ),
          const Gap(AppSpacing.md),
          _Line(icon: Icons.directions_car_outlined, text: siniestro.vehiculoResumen),
          const Gap(AppSpacing.xs),
          _Line(
              icon: Icons.schedule,
              text: DateFormatEs.fechaHora(siniestro.fechaSiniestro)),
          if (siniestro.indicacionesDanoInterno) ...[
            const Gap(AppSpacing.xs),
            _Line(
              icon: Icons.warning_amber_outlined,
              text: 'El cliente sospecha daño interno',
              color: AppColors.amber,
            ),
          ],
          const Gap(AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onValidar,
              icon: const Icon(Icons.fact_check_outlined, size: 18),
              label: const Text('Iniciar Validación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                foregroundColor: AppColors.blueprint,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.color});
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? context.textSecondaryColor),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
