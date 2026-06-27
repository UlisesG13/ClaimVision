import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../auth/presentation/state/onboarding_controller.dart';
import '../state/mis_siniestros_provider.dart';
import '../state/notificaciones_provider.dart';
import '../state/report_controller.dart';
import '../widgets/siniestro_card.dart';

/// Inicio del Cliente (Figma node 70:344).
///
/// Saluda al usuario autenticado, ofrece reportar un incidente y muestra la
/// actividad reciente de SUS siniestros. Como el backend aún no expone un
/// listado de siniestros del cliente, la actividad se alimenta de los creados
/// en la sesión ([misSiniestrosProvider]); si no hay, se muestra un estado
/// vacío honesto.
class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(currentSessionProvider);
    final siniestros = ref.watch(misSiniestrosProvider);
    final store = ref.read(misSiniestrosProvider.notifier);
    final poliza = ref.watch(
      onboardingControllerProvider.select((s) => s.numeroPoliza),
    );

    final nombre = _nombreDesdeEmail(session?.email);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: ClaimVisionBottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              context.go(RoutePaths.historial);
            case 2:
              context.go(RoutePaths.perfil);
          }
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Header(
              nombre: nombre,
              poliza: poliza,
              noLeidas: ref.watch(notificacionesNoLeidasProvider),
              onLogout: () => _confirmLogout(context, ref),
              onBell: () => context.push(RoutePaths.notificaciones),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReportCard(
                    onTap: () {
                      // Nuevo reporte: limpia el borrador previo.
                      ref.read(reportControllerProvider.notifier).reset();
                      context.push(RoutePaths.reportar);
                    },
                  ),
                  const Gap(AppSpacing.lg),
                  _StatsRow(
                    activos: store.activos,
                    total: store.total,
                  ),
                  const Gap(AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Actividad Reciente',
                          style: theme.textTheme.titleLarge),
                      if (siniestros.isNotEmpty)
                        GestureDetector(
                          onTap: () => context.go(RoutePaths.historial),
                          child: Text('Ver todos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.blueprint,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  if (siniestros.isEmpty)
                    const _EmptyActivity()
                  else
                    ...siniestros.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: SiniestroCard(
                            siniestro: s,
                            onTap: () => context.push(
                                RoutePaths.detalleSiniestroDe(s.id)),
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nombreDesdeEmail(String? email) {
    if (email == null || email.isEmpty) return 'Cliente';
    final local = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final salir = await AppDialog.confirm(
      context,
      title: 'Cerrar sesión',
      message:
          '¿Seguro que deseas salir de tu cuenta? Deberás iniciar sesión nuevamente.',
      confirmLabel: 'Cerrar sesión',
      danger: true,
    );
    if (salir) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.nombre,
    required this.poliza,
    required this.noLeidas,
    required this.onLogout,
    required this.onBell,
  });

  final String nombre;
  final String poliza;
  final int noLeidas;
  final VoidCallback onLogout;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iniciales = nombre.trim().isEmpty
        ? 'CL'
        : nombre
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase();
    final subtitulo =
        poliza.trim().isEmpty ? 'Bienvenido' : 'Póliza $poliza';

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLogout,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.blueprint,
              child: Text(
                iniciales,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $nombre', style: theme.textTheme.titleLarge),
                Text(subtitulo, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onBell,
                icon: const Icon(Icons.notifications_none,
                    color: AppColors.blueprint),
              ),
              if (noLeidas > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                        color: AppColors.alert, shape: BoxShape.circle),
                    child: Text(
                      noLeidas > 9 ? '9+' : '$noLeidas',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.onTap});
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
          color: AppColors.blueprint,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueprint.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.add, color: AppColors.blueprint, size: 26),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reportar Incidente',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      )),
                  Text('Inicia un nuevo siniestro',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward,
                color: AppColors.white.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.activos, required this.total});
  final int activos;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(value: activos, label: 'Activos')),
        const Gap(AppSpacing.md),
        Expanded(child: _StatBox(value: total, label: 'Total')),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value',
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 32)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 40, color: AppColors.textHint),
          const Gap(AppSpacing.md),
          Text('Aún no has reportado siniestros',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.xs),
          Text(
            'Cuando reportes un incidente aparecerá aquí con su estado.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
