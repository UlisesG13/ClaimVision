import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/ia/data/dtos/ia_nlp_dto.dart';
import '../../../../core/ia/data/dtos/ia_v2_dto.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/state/sse_providers.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../state/mis_siniestros_controller.dart';
import '../widgets/siniestro_card.dart';


class HistorialPage extends ConsumerWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    ref.listen(sseEventStreamProvider, (_, next) {
      next.whenData((event) {
        if (event.isSiniestro && event.esStatusChange) {
          ref.invalidate(misSiniestrosControllerProvider);
        }
      });
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.scaffoldBgColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          automaticallyImplyLeading: false,
          title: Text('Historial', style: theme.textTheme.titleLarge),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Siniestros', icon: Icon(Icons.assignment_outlined)),
              Tab(text: 'Análisis IA', icon: Icon(Icons.auto_awesome)),
            ],
          ),
        ),
        bottomNavigationBar: ClaimVisionBottomNav(
          currentIndex: 1,
          onTap: (i) {
            switch (i) {
              case 0:
                context.go(RoutePaths.inicio);
              case 2:
                context.go(RoutePaths.perfil);
            }
          },
        ),
        body: const TabBarView(
          children: [
            _SiniestrosTab(),
            _AnalisisIaTab(),
          ],
        ),
      ),
    );
  }
}

class _SiniestrosTab extends ConsumerWidget {
  const _SiniestrosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siniestrosAsync = ref.watch(misSiniestrosControllerProvider);

    return siniestrosAsync.when(
      data: (siniestros) {
        if (siniestros.isEmpty) return const _Empty();
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(misSiniestrosControllerProvider);
            await ref.read(misSiniestrosControllerProvider.future);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: siniestros.length,
            separatorBuilder: (_, _) => const Gap(AppSpacing.md),
            itemBuilder: (context, i) {
              final s = siniestros[i];
              return SiniestroCard(
                siniestro: s,
                onTap: () =>
                    context.push(RoutePaths.detalleSiniestroDe(s.id)),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _Empty(),
    );
  }
}

class _AnalisisIaTab extends ConsumerWidget {
  const _AnalisisIaTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final v2Async = ref.watch(iaV2HistoryProvider);
    final nlpAsync = ref.watch(iaNlpHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(iaV2HistoryProvider);
        ref.invalidate(iaNlpHistoryProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text('Predicciones de daño', style: theme.textTheme.titleMedium),
          const Gap(AppSpacing.md),
          v2Async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _IaError(
              message: 'No se pudo cargar el historial de predicciones.',
            ),
            data: (page) => page.data.isEmpty
                ? _IaVacio(texto: 'Aún no hay predicciones registradas.')
                : Column(
                    children: [
                      for (final item in page.data) _V2HistoryTile(item: item),
                    ],
                  ),
          ),
          const Gap(AppSpacing.xl),
          Text('Transcripciones de voz', style: theme.textTheme.titleMedium),
          const Gap(AppSpacing.md),
          nlpAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _IaError(
              message: 'No se pudo cargar el historial de transcripciones.',
            ),
            data: (page) => page.data.isEmpty
                ? _IaVacio(texto: 'Aún no hay transcripciones registradas.')
                : Column(
                    children: [
                      for (final item in page.data) _NlpHistoryTile(item: item),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _V2HistoryTile extends StatelessWidget {
  const _V2HistoryTile({required this.item});
  final IaV2HistoryItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blueprint.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.car_crash_outlined, color: AppColors.blueprint),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.tipoDano} · ${item.severidad}',
                    style: theme.textTheme.labelLarge),
                Text(
                  '${item.filename} · ${(item.confianza * 100).toStringAsFixed(0)}% confianza',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            item.createdAt.length >= 10
                ? item.createdAt.substring(0, 10)
                : item.createdAt,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _NlpHistoryTile extends StatelessWidget {
  const _NlpHistoryTile({required this.item});
  final IaNlpHistoryItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_none, color: AppColors.amber),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.texto.isEmpty ? '(sin texto)' : item.texto,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.duracionSeg.toStringAsFixed(0)}s · ${item.entidades.length} daños detectados',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            item.createdAt.length >= 10
                ? item.createdAt.substring(0, 10)
                : item.createdAt,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _IaVacio extends StatelessWidget {
  const _IaVacio({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

class _IaError extends StatelessWidget {
  const _IaError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.alert, size: 18),
          const Gap(AppSpacing.sm),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
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
            Icon(Icons.history, size: 48, color: context.textHintColor),
            const Gap(AppSpacing.md),
            Text('Sin siniestros todavía', style: theme.textTheme.titleMedium),
            const Gap(AppSpacing.xs),
            Text(
              'Los siniestros que reportes aparecerán aquí con su estado.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
