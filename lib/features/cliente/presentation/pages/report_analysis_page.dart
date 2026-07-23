import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ia/data/dtos/ia_batch_dto.dart';
import '../../../../core/ia/data/dtos/ia_nlp_dto.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'package:claimvision/shared/domain/entities/siniestro.dart';
import '../state/report_controller.dart';

class ReportAnalysisPage extends ConsumerStatefulWidget {
  const ReportAnalysisPage({super.key});

  @override
  ConsumerState<ReportAnalysisPage> createState() => _ReportAnalysisPageState();
}

class _ReportAnalysisPageState extends ConsumerState<ReportAnalysisPage> {
  bool _analisisIniciado = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportControllerProvider.notifier).predecirTodasLasFotos());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reportControllerProvider);
    final siniestro = state.siniestro;

    ref.listen(reportControllerProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg != null && msg.isNotEmpty) {
        AppSnackbar.error(context, msg);
      }
    });

    if (!_analisisIniciado && siniestro != null) {
      _analisisIniciado = true;
      Future.microtask(
        () => ref.read(reportControllerProvider.notifier).analizarTexto(),
      );
    }

    final analisisVacio = !state.analizando &&
        state.analisisEntidades.isEmpty &&
        _analisisIniciado;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Análisis Preliminar', style: theme.textTheme.titleLarge),
            Text('Generado por IA', style: theme.textTheme.bodySmall),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: siniestro == null
            ? const Center(child: Text('No hay un reporte activo.'))
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  const _SentHero(),
                  const Gap(AppSpacing.lg),
                  _AnalysisCard(
                    theme: theme,
                    analizando: state.analizando,
                    entidades: state.analisisEntidades,
                    titulo: 'Análisis del relato (IA)',
                    onRetry: analisisVacio
                        ? () => ref
                            .read(reportControllerProvider.notifier)
                            .analizarTexto()
                        : null,
                  ),
                  const Gap(AppSpacing.lg),
                  _AnalysisCard(
                    theme: theme,
                    analizando: state.predictandoBatch,
                    entidades: state.prediccionesFotos,
                    titulo: 'Predicción de daños (IA)',
                  ),
                  const Gap(AppSpacing.lg),
                  _SummaryCard(
                    siniestro: siniestro,
                    fotosValidas: state.evidenciasValidas,
                    danoInterno: state.danoInterno,
                  ),
                  const Gap(AppSpacing.lg),
                  _CostSummaryCard(
                    resumen: state.resumenCosto,
                    loading: state.calculandoCosto,
                  ),
                  const Gap(AppSpacing.lg),
                  const _AdjusterNote(),
                ],
              ),
      ),
      bottomNavigationBar: siniestro == null
          ? null
          : Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl + MediaQuery.viewPaddingOf(context).bottom),
              child: PrimaryButton(
                label: 'Ir al inicio',
                icon: Icons.home_outlined,
                onPressed: () => context.go(RoutePaths.inicio),
              ),
            ),
    );
  }
}

class _SentHero extends StatelessWidget {
  const _SentHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 44),
          const Gap(AppSpacing.md),
          Text('Reporte enviado',
              style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const Gap(AppSpacing.xs),
          Text(
            'Recibimos tu siniestro preliminar. Tu aseguradora ya puede revisarlo.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: context.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.theme,
    required this.analizando,
    required this.entidades,
    required this.titulo,
    this.onRetry,
  });

  final ThemeData theme;
  final bool analizando;
  final List<IaDamageEntityDto> entidades;
  final String titulo;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blueprint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.amber, size: 20),
              const Gap(AppSpacing.sm),
              Text(titulo,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: AppColors.amber)),
            ],
          ),
          const Gap(AppSpacing.md),
          if (analizando)
            const InlineLoading(message: 'Analizando…', color: AppColors.amber),
          if (entidades.isEmpty && !analizando)
            Column(
              children: [
                Text(
                  'No se detectaron daños específicos en la narración.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.white.withValues(alpha: 0.75)),
                ),
                if (onRetry != null) ...[
                  const Gap(AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, color: AppColors.amber, size: 18),
                      label: const Text('Reintentar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amber,
                        side: const BorderSide(color: AppColors.amber),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ...entidades.map((e) => _EntityRow(entity: e)),
        ],
      ),
    );
  }
}

class _EntityRow extends StatelessWidget {
  const _EntityRow({required this.entity});
  final IaDamageEntityDto entity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.amber, size: 18),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entity.parteAfectada} · ${entity.tipoDano}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                ),
                const Gap(2),
                Text(
                  '${entity.sintoma} · ${entity.severidad} '
                  '(${(entity.confianza * 100).toStringAsFixed(0)}%)',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.siniestro,
    required this.fotosValidas,
    required this.danoInterno,
  });

  final Siniestro siniestro;
  final int fotosValidas;
  final bool danoInterno;

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
          Text('Resumen del reporte',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.md),
          _Row(label: 'Folio', value: siniestro.folioCorto),
          _Row(label: 'Estatus', value: siniestro.estatus.label),
          _Row(label: 'Vehículo', value: siniestro.vehiculoResumen),
          _Row(label: 'Fecha', value: DateFormatEs.fechaHora(siniestro.fechaSiniestro)),
          _Row(label: 'Fotos válidas', value: '$fotosValidas'),
          _Row(
            label: 'Sospecha de daño interno',
            value: danoInterno ? 'Sí' : 'No',
          ),
          if ((siniestro.narracionTexto ?? '').isNotEmpty) ...[
            const Gap(AppSpacing.sm),
            Text('Narración', style: theme.textTheme.bodySmall),
            const Gap(AppSpacing.xs),
            Text(siniestro.narracionTexto!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({required this.resumen, required this.loading});

  final IaResumenResponseDto? resumen;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blueprint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blueprint.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.blueprint, size: 20),
              const Gap(AppSpacing.sm),
              Text('Costo estimado de reparación',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: AppColors.blueprint)),
            ],
          ),
          const Gap(AppSpacing.md),
          if (loading)
            const InlineLoading(message: 'Calculando costo…'),
          if (resumen == null && !loading)
            Text(
              'Completa la predicción de daños para ver el costo estimado.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.textSecondaryColor),
            ),
          if (resumen != null) ...[
            Text(
              '${resumen!.precioTotal.toStringAsFixed(2)} ${resumen!.moneda}',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.blueprint),
            ),
            const Gap(AppSpacing.sm),
            ...resumen!.danos.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${d.tipo} · ${d.severidad}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '\$${d.costoReparacion.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdjusterNote extends StatelessWidget {
  const _AdjusterNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.blueprint),
          const Gap(AppSpacing.md),
          Expanded(
            child: Text(
              'La evaluación de la IA es preliminar. Un ajustador la validará en '
              'sitio antes de cualquier dictamen.',
              style: theme.textTheme.bodySmall?.copyWith(color: context.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
