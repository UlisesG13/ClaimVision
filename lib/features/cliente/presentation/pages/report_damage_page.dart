import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/report_controller.dart';
import '../widgets/report_step_header.dart';

class ReportDamagePage extends ConsumerWidget {
  const ReportDamagePage({super.key});

  Future<void> _capturar(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.surfaceColor,
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
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.blueprint),
              title: const Text('Tomar fotografía'),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.blueprint),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.pop(context, false),
            ),
            const Gap(AppSpacing.sm),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ref.read(imagePickerServiceProvider);
    final file = source ? await picker.fromCamera() : await picker.fromGallery();
    if (file == null) return;
    if (!context.mounted) return;
    LoadingOverlay.show(context, message: 'Subiendo evidencia…');
    await ref.read(reportControllerProvider.notifier).subirEvidencia(file);
    if (context.mounted) LoadingOverlay.hide(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(reportControllerProvider);

    ref.listen(reportControllerProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg != null && msg.isNotEmpty) {
        AppSnackbar.error(context, msg);
      }
    });

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportStepHeader(
              subtitulo: 'Evidencia',
              pasoActual: 4,
              totalPasos: 4,
              onBack: () => context.canPop() ? context.pop() : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text('Fotografía los daños del vehículo',
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                  const Gap(AppSpacing.lg),
                  _CaptureCard(onTap: () => _capturar(context, ref)),
                  if (state.evidencias.isNotEmpty) ...[
                    const Gap(AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        for (final e in state.evidencias)
                          _Thumb(
                            evidencia: e,
                            onRemove: () => ref
                                .read(reportControllerProvider.notifier)
                                .quitarEvidencia(e),
                          ),
                        _AddTile(onTap: () => _capturar(context, ref)),
                      ],
                    ),
                    if (state.predictandoBatch)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.md),
                        child: InlineLoading(message: 'Analizando fotos con IA…'),
                      ),
                  ],
                  const Gap(AppSpacing.lg),
                  _StatusLine(
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    text:
                        '${state.evidenciasValidas} fotos con calidad válida',
                  ),
                  const Gap(AppSpacing.xs),
                  _StatusLine(
                    icon: Icons.info_outline,
                    color: AppColors.amber,
                    text: 'Toma al menos 3 ángulos del daño.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: 'Enviar Reporte',
                icon: Icons.send,
                isLoading: state.subiendoAlguna,
                onPressed: state.puedeEnviar
                    ? () => context.push(RoutePaths.reportarAnalisis)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.blueprint.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.blueprint.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.photo_camera, color: AppColors.blueprint, size: 30),
            ),
            const Gap(AppSpacing.md),
            Text('Tomar fotografía', style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.evidencia, required this.onRemove});
  final Evidencia evidencia;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Image.file(evidencia.file, fit: BoxFit.cover),
          ),
          Positioned(
            left: 4,
            bottom: 4,
            child: _QualityBadge(
              valida: evidencia.calidadValida,
              error: evidencia.error != null,
            ),
          ),
          if (evidencia.prediccionLista)
            Positioned(
              left: 4,
              top: 4,
              child: _PredictBadge(evidencia: evidencia),
            ),
          Positioned(
            right: 2,
            top: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 14, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictBadge extends StatelessWidget {
  const _PredictBadge({required this.evidencia});
  final Evidencia evidencia;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.blueprint,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        evidencia.tipoDano!.length > 8
            ? '${evidencia.tipoDano!.substring(0, 7)}…'
            : evidencia.tipoDano!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.valida, required this.error});
  final bool? valida;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = error
        ? (Icons.error, AppColors.alert)
        : valida == true
            ? (Icons.check_circle, AppColors.success)
            : (Icons.warning, AppColors.amber);
    return Container(
      decoration: const BoxDecoration(
          color: AppColors.white, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: context.borderColor),
        ),
        child: Icon(Icons.add, color: context.textSecondaryColor),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(
      {required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
