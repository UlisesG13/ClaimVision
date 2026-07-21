import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../state/casos_asignados_controller.dart';
import '../state/peritaje_editor_controller.dart';

/// Peritaje Confirmado (Figma node 73:1285).
///
/// Confirmación tras guardar y bloquear el peritaje. Muestra el resultado real
/// (estatus `Peritaje_Validado`, costo, fecha) desde el borrador del editor.
class PeritajeConfirmadoPage extends ConsumerWidget {
  const PeritajeConfirmadoPage({super.key, required this.siniestroId});

  final String siniestroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(peritajeEditorControllerProvider);
    final Siniestro? siniestro = state.resultado;
    final session = ref.watch(currentSessionProvider);
    final ajustador = _nombre(session?.email);

    // Refresca la bandeja al montar para que el estatus del caso esté actualizado.
    ref.invalidate(casosAsignadosControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => context.go(RoutePaths.casos),
            icon: const Icon(Icons.assignment_outlined, size: 18),
            label: const Text('Volver a Mis Casos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: AppColors.blueprint,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const Gap(AppSpacing.xl),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified,
                    color: AppColors.success, size: 48),
              ),
            ),
            const Gap(AppSpacing.lg),
            Text('Peritaje Confirmado',
                textAlign: TextAlign.center, style: theme.textTheme.displayMedium),
            const Gap(AppSpacing.sm),
            Text(
              'El peritaje fue registrado y firmado digitalmente. El expediente '
              'pasó a validación de la aseguradora.',
              textAlign: TextAlign.center,
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: context.textSecondaryColor),
            ),
            const Gap(AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  _fila(context, theme, 'Estatus',
                      siniestro?.estatus.label ?? 'Peritaje validado'),
                  _fila(context, theme, 'Caso', siniestro?.folioCorto ?? '—'),
                  _fila(context, theme, 'Costo definitivo', _money(state.costoDefinitivo)),
                  _fila(context, theme, 'Daños validados', '${state.danos.length}'),
                  _fila(context, theme, 'Firmado por', ajustador),
                  _fila(context, theme, 'Fecha', DateFormatEs.fechaHora(DateTime.now())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(BuildContext context, ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.textSecondaryColor)),
          ),
          Text(value,
              style:
                  theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _nombre(String? email) {
    if (email == null || email.isEmpty) return 'Ajustador';
    final local = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

String _money(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '\$$buf MXN';
}
