import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/state/sse_providers.dart';
import '../../../../shared/utils/date_format.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:claimvision/shared/domain/entities/siniestro_status.dart';
import '../state/mis_siniestros_controller.dart';

class SiniestroDetailPage extends ConsumerWidget {
  const SiniestroDetailPage({super.key, required this.siniestroId});

  final String siniestroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    ref.listen(siniestroSseProvider(siniestroId), (_, next) {
      next.whenData((_) {
        ref.invalidate(misSiniestrosControllerProvider);
      });
    });

    final siniestrosAsync = ref.watch(misSiniestrosControllerProvider);
    final siniestro = siniestrosAsync.asData?.value
        .where((s) => s.id == siniestroId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: siniestro == null
            ? const Text('Detalle del siniestro')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Siniestro ${siniestro.folioCorto}',
                      style: theme.textTheme.titleLarge),
                  Text('${siniestro.vehiculoMarca} ${siniestro.vehiculoModelo} ${siniestro.vehiculoAnio}',
                      style: theme.textTheme.bodySmall),
                ],
              ),
      ),
      body: siniestro == null
          ? const _NotFound()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _CurrentStateCard(siniestro: siniestro),
                const Gap(AppSpacing.lg),
                Text('Seguimiento', style: theme.textTheme.titleLarge),
                const Gap(AppSpacing.md),
                _Timeline(siniestro: siniestro),
                if (siniestro.ajustadorId != null) ...[
                  const Gap(AppSpacing.lg),
                  const _AdjusterCard(),
                ],
                if ((siniestro.narracionTexto ?? '').isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  _NarrationCard(texto: siniestro.narracionTexto!),
                ],
              ],
            ),
    );
  }
}

class _CurrentStateCard extends StatelessWidget {
  const _CurrentStateCard({required this.siniestro});
  final Siniestro siniestro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vin = siniestro.vehiculoVin;
    final detalle = vin != null && vin.isNotEmpty
        ? '${siniestro.vehiculoPlacas} · VIN $vin'
        : siniestro.vehiculoPlacas;

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
              Text('Estado actual', style: theme.textTheme.bodySmall),
              _EstatusChip(estatus: siniestro.estatus),
            ],
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              Icon(Icons.directions_car_outlined,
                  size: 18, color: context.textSecondaryColor),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(detalle,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: context.textSecondaryColor),
              const Gap(AppSpacing.sm),
              Text(DateFormatEs.fechaHora(siniestro.fechaSiniestro),
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.siniestro});
  final Siniestro siniestro;

  @override
  Widget build(BuildContext context) {
    const estados = SiniestroStatus.values;
    final actual = estados.indexOf(siniestro.estatus);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          for (var i = 0; i < estados.length; i++)
            _TimelineRow(
              estatus: estados[i],
              // El primer estado lleva la fecha real del reporte; el actual se
              // marca "En proceso"; los futuros "Pendiente".
              subtitulo: i == 0
                  ? DateFormatEs.fechaHora(siniestro.fechaSiniestro)
                  : i < actual
                      ? 'Completado'
                      : i == actual
                          ? 'En proceso'
                          : 'Pendiente',
              estado: i < actual
                  ? _PasoEstado.completado
                  : i == actual
                      ? _PasoEstado.actual
                      : _PasoEstado.pendiente,
              esUltimo: i == estados.length - 1,
            ),
        ],
      ),
    );
  }
}

enum _PasoEstado { completado, actual, pendiente }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.estatus,
    required this.subtitulo,
    required this.estado,
    required this.esUltimo,
  });

  final SiniestroStatus estatus;
  final String subtitulo;
  final _PasoEstado estado;
  final bool esUltimo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (estado) {
      _PasoEstado.completado => AppColors.success,
      _PasoEstado.actual => AppColors.amber,
      _PasoEstado.pendiente => context.borderColor,
    };
    final activo = estado != _PasoEstado.pendiente;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: estado == _PasoEstado.completado
                      ? AppColors.success
                      : context.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: estado == _PasoEstado.completado
                    ? const Icon(Icons.check, size: 14, color: AppColors.white)
                    : estado == _PasoEstado.actual
                        ? const Center(
                            child: CircleAvatar(
                                radius: 4, backgroundColor: AppColors.amber))
                        : null,
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(
                    width: 2,
                    color: estado == _PasoEstado.completado
                        ? AppColors.success
                        : context.borderColor,
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(estatus.label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: activo
                            ? context.textPrimaryColor
                            : context.textHintColor,
                      )),
                  Text(subtitulo, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdjusterCard extends StatelessWidget {
  const _AdjusterCard();

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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.blueprint,
            child: Icon(Icons.engineering_outlined, color: AppColors.white),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ajustador asignado', style: theme.textTheme.labelLarge),
                Text('Validará tu peritaje en sitio.',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrationCard extends StatelessWidget {
  const _NarrationCard({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu narración',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const Gap(AppSpacing.sm),
          Text(texto, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _EstatusChip extends StatelessWidget {
  const _EstatusChip({required this.estatus});
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

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: context.textHintColor),
            const Gap(AppSpacing.md),
            Text('No encontramos este siniestro',
                style: theme.textTheme.titleMedium),
            const Gap(AppSpacing.xs),
            Text(
              'El detalle solo está disponible para los siniestros reportados '
              'en esta sesión. Reporta o vuelve a iniciar para verlo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
