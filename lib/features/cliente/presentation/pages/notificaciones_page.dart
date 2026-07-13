import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../state/notificaciones_controller.dart';

/// Notificaciones - Cliente (Figma node 79:5167).
///
/// Lista las notificaciones del cliente agrupadas por día (Hoy / Ayer /
/// Anteriores), con acción "Leer todo". Las notificaciones se derivan de los
/// siniestros reportados en la sesión (el backend aún no expone un listado).
class NotificacionesPage extends ConsumerWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificaciones = ref.watch(notificacionesProvider);
    final hayNoLeidas = notificaciones.any((n) => !n.leida);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: Text('Notificaciones', style: theme.textTheme.titleLarge),
        actions: [
          if (hayNoLeidas)
            TextButton.icon(
              onPressed: () => ref
                  .read(notificacionesControllerProvider.notifier)
                  .marcarLeidas(notificaciones.map((n) => n.id)),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Leer todo'),
              style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
            ),
        ],
      ),
      body: notificaciones.isEmpty
          ? const _Empty()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: _construirSecciones(context, ref, notificaciones),
            ),
    );
  }

  List<Widget> _construirSecciones(
    BuildContext context,
    WidgetRef ref,
    List<Notificacion> todas,
  ) {
    final hoy = <Notificacion>[];
    final ayer = <Notificacion>[];
    final anteriores = <Notificacion>[];
    final ahora = DateTime.now();
    final inicioHoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicioAyer = inicioHoy.subtract(const Duration(days: 1));

    for (final n in todas) {
      final f = n.fecha.toLocal();
      if (!f.isBefore(inicioHoy)) {
        hoy.add(n);
      } else if (!f.isBefore(inicioAyer)) {
        ayer.add(n);
      } else {
        anteriores.add(n);
      }
    }

    final widgets = <Widget>[];
    void seccion(String titulo, List<Notificacion> items) {
      if (items.isEmpty) return;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
        child: Text(titulo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: context.textSecondaryColor,
                )),
      ));
      for (final n in items) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _NotificacionTile(
            notificacion: n,
            onTap: () =>
                ref.read(notificacionesControllerProvider.notifier).marcarLeida(n.id),
          ),
        ));
      }
    }

    seccion('HOY', hoy);
    seccion('AYER', ayer);
    seccion('ANTERIORES', anteriores);
    return widgets;
  }
}

class _NotificacionTile extends StatelessWidget {
  const _NotificacionTile({required this.notificacion, required this.onTap});
  final Notificacion notificacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (notificacion.tipo) {
      NotificacionTipo.reporte => (Icons.assignment_turned_in_outlined, AppColors.blueprint),
      NotificacionTipo.estado => (Icons.sync, AppColors.amber),
    };
    final hora = _hora(notificacion.fecha);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notificacion.leida
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notificacion.titulo,
                            style: theme.textTheme.labelLarge),
                      ),
                      Text(hora, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const Gap(2),
                  Text(notificacion.cuerpo,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: context.textSecondaryColor)),
                ],
              ),
            ),
            if (!notificacion.leida)
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

  String _hora(DateTime f) {
    final l = f.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
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
            Text(
              'Aquí verás avisos sobre tus siniestros: asignación de ajustador, '
              'validación del peritaje y entrega del vehículo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
