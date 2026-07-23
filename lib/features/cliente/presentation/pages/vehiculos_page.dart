import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import '../state/mis_siniestros_controller.dart';

class VehiculosPage extends ConsumerWidget {
  const VehiculosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final siniestrosAsync = ref.watch(misSiniestrosControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: Text('Vehículos registrados', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(top: false, child: siniestrosAsync.when(
        data: (siniestros) {
          final porPlacas = <String, Siniestro>{};
          for (final s in siniestros) {
            porPlacas.putIfAbsent(s.vehiculoPlacas.toUpperCase(), () => s);
          }
          final vehiculos = porPlacas.values.toList();

          if (vehiculos.isEmpty) return const _Empty();
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: vehiculos.length,
            separatorBuilder: (_, _) => const Gap(AppSpacing.md),
            itemBuilder: (context, i) => _VehiculoCard(siniestro: vehiculos[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Empty(),
      ),
      ),
    );
  }
}

class _VehiculoCard extends StatelessWidget {
  const _VehiculoCard({required this.siniestro});
  final Siniestro siniestro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vin = siniestro.vehiculoVin;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.blueprint.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.blueprint),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${siniestro.vehiculoMarca} ${siniestro.vehiculoModelo} ${siniestro.vehiculoAnio}',
                  style: theme.textTheme.labelLarge,
                ),
                const Gap(2),
                Text('Placas: ${siniestro.vehiculoPlacas}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: context.textSecondaryColor)),
                if (vin != null && vin.isNotEmpty)
                  Text('VIN: $vin',
                      style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined,
                size: 48, color: context.textHintColor),
            const Gap(AppSpacing.md),
            Text('Sin vehículos registrados', style: theme.textTheme.titleMedium),
            const Gap(AppSpacing.xs),
            Text(
              'Cuando reportes un siniestro, el vehículo aparecerá aquí.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
