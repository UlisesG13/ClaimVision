import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../state/casos_asignados_controller.dart';
import '../state/peritaje_editor_controller.dart';
import '../widgets/signature_pad.dart';

/// Firma del Peritaje (Figma node 73:1235).
///
/// Muestra el resumen del peritaje y captura la firma del ajustador (lienzo
/// nativo → base64). Al confirmar, registra el peritaje (`POST`), y avanza a la
/// pantalla de confirmación.
class FirmaPeritajePage extends ConsumerStatefulWidget {
  const FirmaPeritajePage({super.key, required this.siniestroId});

  final String siniestroId;

  @override
  ConsumerState<FirmaPeritajePage> createState() => _FirmaPeritajePageState();
}

class _FirmaPeritajePageState extends ConsumerState<FirmaPeritajePage> {
  final _firma = SignatureController();

  @override
  void dispose() {
    _firma.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color? color}) {
    if (color == AppColors.alert) {
      AppSnackbar.error(context, msg);
    } else {
      AppSnackbar.warning(context, msg);
    }
  }

  Future<void> _confirmar() async {
    if (_firma.isEmpty) {
      _snack('Firma el peritaje para continuar.');
      return;
    }
    final base64 = await _firma.toBase64();
    if (base64 == null) {
      _snack('No se pudo capturar la firma. Inténtalo de nuevo.');
      return;
    }
    final controller = ref.read(peritajeEditorControllerProvider.notifier);
    controller.setFirma(base64);
    final ok = await controller.registrarYConfirmar();
    if (ok && mounted) {
      // Refresca la bandeja para reflejar el nuevo estatus del caso.
      ref.invalidate(casosAsignadosControllerProvider);
      context.go(RoutePaths.peritajeConfirmadoDe(widget.siniestroId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(peritajeEditorControllerProvider);
    final session = ref.watch(currentSessionProvider);
    final ajustador = _nombre(session?.email);

    ref.listen(peritajeEditorControllerProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg != null && msg.isNotEmpty) _snack(msg, color: AppColors.alert);
    });

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: Text('Firma del Peritaje', style: theme.textTheme.titleLarge),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: state.submitting ? null : _confirmar,
            icon: state.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.blueprint),
                  )
                : const Icon(Icons.verified_outlined, size: 18),
            label: Text(state.submitting
                ? 'Registrando…'
                : 'Confirmar y firmar peritaje'),
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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _Resumen(
            danos: state.danos.length,
            costo: state.costoDefinitivo,
            ajustador: ajustador,
          ),
          const Gap(AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Firma digital del ajustador',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
              TextButton.icon(
                onPressed: () => setState(_firma.clear),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Borrar'),
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          SignaturePad(controller: _firma),
          const Gap(AppSpacing.xs),
          Center(
            child: Text('Firma aquí con el dedo',
                style: theme.textTheme.bodySmall),
          ),
          const Gap(AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.gavel, color: AppColors.blueprint, size: 18),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Al firmar, confirmas y bloqueas el peritaje como definitivo.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
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

class _Resumen extends StatelessWidget {
  const _Resumen(
      {required this.danos, required this.costo, required this.ajustador});
  final int danos;
  final double costo;
  final String ajustador;

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
          Text('Resumen', style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.md),
          _fila(context, theme, 'Daños validados', '$danos'),
          _fila(context, theme, 'Costo definitivo', _money(costo)),
          _fila(context, theme, 'Ajustador', ajustador),
        ],
      ),
    );
  }

  Widget _fila(BuildContext context, ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
