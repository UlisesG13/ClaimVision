import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:claimvision/shared/domain/entities/siniestro_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../cliente/presentation/widgets/siniestro_card.dart';
import '../state/casos_asignados_controller.dart';
import '../state/peritaje_editor_controller.dart';

/// Detalle del Caso - Ajustador (Figma node 73:1073).
///
/// Muestra los datos técnicos del siniestro asignado y permite iniciar la
/// validación del peritaje. Los datos vienen de la bandeja de casos asignados.
class CasoDetallePage extends ConsumerWidget {
  const CasoDetallePage({super.key, required this.siniestroId});

  final String siniestroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final casosAsync = ref.watch(casosAsignadosControllerProvider);
    final Siniestro? siniestro = casosAsync.asData?.value
        .where((s) => s.id == siniestroId)
        .firstOrNull;
    final puedeValidar = siniestro?.estatus == SiniestroStatus.asignadoAjustador;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: siniestro == null
            ? const Text('Detalle del caso')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Caso ${siniestro.folioCorto}',
                      style: theme.textTheme.titleLarge),
                  Text(
                      '${siniestro.vehiculoMarca} ${siniestro.vehiculoModelo} ${siniestro.vehiculoAnio}',
                      style: theme.textTheme.bodySmall),
                ],
              ),
      ),
      bottomNavigationBar: siniestro == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: puedeValidar
                      ? () {
                          ref
                              .read(peritajeEditorControllerProvider.notifier)
                              .iniciar(siniestro.id);
                          context.push(RoutePaths.validacionPeritajeDe(siniestro.id));
                        }
                      : null,
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: Text(puedeValidar ? 'Iniciar Validación' : siniestro.estatus.label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: puedeValidar ? AppColors.amber : context.textHintColor,
                    foregroundColor: puedeValidar ? AppColors.blueprint : AppColors.white,
                    elevation: 0,
                    disabledBackgroundColor: context.textHintColor,
                    disabledForegroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
              ),
            ),
      body: siniestro == null
          ? const Center(child: Text('No encontramos este caso.'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Row(
                  children: [
                    SiniestroStatusChip(estatus: siniestro.estatus),
                    if (siniestro.indicacionesDanoInterno) ...[
                      const Gap(AppSpacing.sm),
                      _Tag(
                        text: 'Posible daño interno',
                        color: AppColors.amber,
                      ),
                    ],
                  ],
                ),
                const Gap(AppSpacing.lg),
                _Section(
                  titulo: 'Datos del siniestro',
                  filas: [
                    ('Vehículo',
                        '${siniestro.vehiculoMarca} ${siniestro.vehiculoModelo} ${siniestro.vehiculoAnio}'),
                    ('Placas', siniestro.vehiculoPlacas),
                    if ((siniestro.vehiculoVin ?? '').isNotEmpty)
                      ('VIN', siniestro.vehiculoVin!),
                    ('Fecha', DateFormatEs.fechaHora(siniestro.fechaSiniestro)),
                    ('Daño interno reportado',
                        siniestro.indicacionesDanoInterno ? 'Sí' : 'No'),
                  ],
                ),
                const Gap(AppSpacing.lg),
                _MapLink(
                  latitud: siniestro.latitud,
                  longitud: siniestro.longitud,
                ),
                if ((siniestro.narracionTexto ?? '').isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  _NarracionCard(texto: siniestro.narracionTexto!),
                ],
              ],
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titulo, required this.filas});
  final String titulo;
  final List<(String, String)> filas;

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
          Text(titulo, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.md),
          for (final (label, value) in filas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(label,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: context.textSecondaryColor)),
                  ),
                  Expanded(
                    child: Text(value,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NarracionCard extends StatelessWidget {
  const _NarracionCard({required this.texto});
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
          Text('Narración del cliente',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const Gap(AppSpacing.sm),
          Text(texto, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MapLink extends StatelessWidget {
  const _MapLink({required this.latitud, required this.longitud});

  final double latitud;
  final double longitud;

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
      child: InkWell(
        onTap: () => launchUrl(
          Uri.parse('https://www.google.com/maps?q=$latitud,$longitud'),
          mode: LaunchMode.externalApplication,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.blueprint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.map_outlined, color: AppColors.blueprint),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ubicación del siniestro',
                      style: theme.textTheme.labelLarge),
                  const Gap(2),
                  Text(
                    '${latitud.toStringAsFixed(5)}, ${longitud.toStringAsFixed(5)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, size: 18, color: AppColors.blueprint),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color, fontWeight: FontWeight.w600)),
    );
  }
}
