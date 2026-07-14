import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../state/mis_siniestros_controller.dart';
import '../widgets/siniestro_card.dart';


class HistorialPage extends ConsumerWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final siniestrosAsync = ref.watch(misSiniestrosControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        automaticallyImplyLeading: false,
        title: Text('Historial', style: theme.textTheme.titleLarge),
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
      body: siniestrosAsync.when(
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
