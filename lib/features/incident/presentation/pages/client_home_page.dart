import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../auth/presentation/state/onboarding_controller.dart';
import '../../domain/entities/siniestro.dart';
import '../../domain/entities/siniestro_estatus.dart';
import '../state/mis_siniestros_provider.dart';
import '../state/report_controller.dart';

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
            case 2:
              context.go(RoutePaths.perfil);
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial — próximamente.')),
              );
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
              onLogout: () => _confirmLogout(context, ref),
              onBell: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones — próximamente.')),
              ),
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
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Historial — próximamente.')),
                          ),
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
                          child: _SiniestroCard(
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
    final salir = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.alert),
              title: const Text('Cerrar sesión'),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context, false),
            ),
            const Gap(AppSpacing.sm),
          ],
        ),
      ),
    );
    if (salir == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.nombre,
    required this.poliza,
    required this.onLogout,
    required this.onBell,
  });

  final String nombre;
  final String poliza;
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
          IconButton(
            onPressed: onBell,
            icon: const Icon(Icons.notifications_none, color: AppColors.blueprint),
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

class _SiniestroCard extends StatelessWidget {
  const _SiniestroCard({required this.siniestro, required this.onTap});
  final Siniestro siniestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fecha = DateFormatEs.fechaHora(siniestro.fechaSiniestro);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Siniestro ${siniestro.folioCorto}',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                _EstatusChip(estatus: siniestro.estatus),
              ],
            ),
            const Gap(AppSpacing.md),
            _IconLine(
                icon: Icons.directions_car_outlined,
                text: siniestro.vehiculoResumen),
            const Gap(AppSpacing.xs),
            _IconLine(icon: Icons.schedule, text: fecha),
          ],
        ),
      ),
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
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _EstatusChip extends StatelessWidget {
  const _EstatusChip({required this.estatus});
  final SiniestroEstatus estatus;

  @override
  Widget build(BuildContext context) {
    final color = switch (estatus.tono) {
      SiniestroEstatusTono.neutro => AppColors.textSecondary,
      SiniestroEstatusTono.proceso => AppColors.amber,
      SiniestroEstatusTono.info => AppColors.blueprint,
      SiniestroEstatusTono.exito => AppColors.success,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        estatus.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
