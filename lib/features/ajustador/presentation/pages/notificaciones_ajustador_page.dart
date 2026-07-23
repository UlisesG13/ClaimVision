import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/state/notificaciones_controller.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/ajustador_bottom_nav.dart';
import '../state/casos_asignados_controller.dart';
import '../../../../shared/widgets/async_value_widget.dart';

/// Notificaciones - Ajustador (Figma node 79:5270).
///
/// Avisos derivados de los casos asignados (el backend no expone un listado de
/// notificaciones). Cada caso asignado genera un aviso "Caso asignado".
class NotificacionesAjustadorPage extends ConsumerWidget {
  const NotificacionesAjustadorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final casosAsync = ref.watch(casosAsignadosControllerProvider);
    final leidas = ref.watch(notificacionesLeidasProvider);
    final casos = casosAsync.asData?.value ?? const <Siniestro>[];
    final hayNoLeidas = casos.any((c) => !leidas.contains('caso_${c.id}'));

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        automaticallyImplyLeading: false,
        title: Text('Notificaciones', style: theme.textTheme.titleLarge),
        actions: [
          if (hayNoLeidas)
            TextButton.icon(
              onPressed: () => ref
                      .read(notificacionesControllerProvider.notifier)
                  .marcarLeidas(casos.map((c) => 'caso_${c.id}')),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Leer todo'),
              style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
            ),
        ],
      ),
      bottomNavigationBar: AjustadorBottomNav(
        currentIndex: 1,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go(RoutePaths.casos);
            case 2:
              context.go(RoutePaths.perfil);
          }
        },
      ),
      body: SafeArea(top: false, child: AsyncValueWidget(
        value: casosAsync,
        data: (casos) {
          if (casos.isEmpty) return const _Empty();
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: casos.length,
            separatorBuilder: (_, _) => const Gap(AppSpacing.md),
            itemBuilder: (context, i) {
              final s = casos[i];
              final id = 'caso_${s.id}';
              return _Tile(
                siniestro: s,
                leida: leidas.contains(id),
                onTap: () {
                  ref
                  .read(notificacionesControllerProvider.notifier)
                      .marcarLeida(id);
                  context.push(RoutePaths.casoDetalleDe(s.id));
                },
              );
            },
          );
        },
      ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(
      {required this.siniestro, required this.leida, required this.onTap});
  final Siniestro siniestro;
  final bool leida;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: leida
              ? context.cardColor
              : AppColors.blueprint.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.blueprint.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined,
                  size: 20, color: AppColors.blueprint),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Caso asignado',
                            style: theme.textTheme.labelLarge),
                      ),
                      Text(DateFormatEs.fechaHora(siniestro.fechaSiniestro),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    'Tienes el caso ${siniestro.folioCorto} (${siniestro.vehiculoResumen}) para validar.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
            if (!leida)
              Container(
                margin: const EdgeInsets.only(left: AppSpacing.sm, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.amber, shape: BoxShape.circle),
              ),
          ],
        ),
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
            Icon(Icons.notifications_none,
                size: 48, color: context.textHintColor),
            const Gap(AppSpacing.md),
            Text('Sin notificaciones', style: theme.textTheme.titleMedium),
            const Gap(AppSpacing.xs),
            Text('Aquí verás los casos que tu aseguradora te asigne.',
                textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
