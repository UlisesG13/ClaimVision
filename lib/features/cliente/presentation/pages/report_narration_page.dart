import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/report_controller.dart';
import '../widgets/report_step_header.dart';

/// Reportar — Paso 3: Narración (Figma node 70:549).
///
/// El cliente describe cómo ocurrió el siniestro e indica si sospecha daño
/// interno. Al continuar se guarda en el backend con `PUT /siniestros/{id}`
/// (`narracion_texto` + `indicaciones_dano_interno`).
class ReportNarrationPage extends ConsumerStatefulWidget {
  const ReportNarrationPage({super.key});

  @override
  ConsumerState<ReportNarrationPage> createState() =>
      _ReportNarrationPageState();
}

class _ReportNarrationPageState extends ConsumerState<ReportNarrationPage> {
  late final TextEditingController _narracion;

  @override
  void initState() {
    super.initState();
    _narracion =
        TextEditingController(text: ref.read(reportControllerProvider).narracionTexto);
  }

  @override
  void dispose() {
    _narracion.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color? color}) {
    if (color == AppColors.alert) {
      AppSnackbar.error(context, msg);
    } else {
      AppSnackbar.show(context, msg);
    }
  }

  Future<void> _continuar() async {
    FocusScope.of(context).unfocus();
    final texto = _narracion.text.trim();
    if (texto.length < 10) {
      _snack('Cuéntanos brevemente qué pasó (al menos 10 caracteres).');
      return;
    }
    final controller = ref.read(reportControllerProvider.notifier);
    controller.setNarracion(texto);
    final ok = await controller.guardarNarracion();
    if (ok && mounted) context.push(RoutePaths.reportarDano);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reportControllerProvider);

    ref.listen(reportControllerProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg != null && msg.isNotEmpty) _snack(msg, color: AppColors.alert);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportStepHeader(
              subtitulo: 'Relato',
              pasoActual: 3,
              totalPasos: 4,
              onBack: () => context.canPop() ? context.pop() : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text('Describe cómo ocurrió',
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                  const Gap(AppSpacing.lg),
                  Text('Narración de los hechos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      )),
                  const Gap(AppSpacing.sm),
                  TextField(
                    controller: _narracion,
                    maxLines: 5,
                    maxLength: 1000,
                    textInputAction: TextInputAction.newline,
                    onChanged: ref.read(reportControllerProvider.notifier).setNarracion,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText:
                          'Ej. Estaba detenido en el semáforo cuando otro vehículo impactó por detrás…',
                      hintStyle: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        borderSide: const BorderSide(color: Color(0xFFC4C6CE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        borderSide: const BorderSide(color: Color(0xFFC4C6CE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        borderSide:
                            const BorderSide(color: AppColors.blueprint, width: 1.5),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  _VoiceNote(onTap: () =>
                      _snack('Grabación de voz — próximamente.')),
                  const Gap(AppSpacing.lg),
                  _DanoInternoTile(
                    value: state.danoInterno,
                    onChanged:
                        ref.read(reportControllerProvider.notifier).setDanoInterno,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                isLoading: state.submitting,
                onPressed: _continuar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceNote extends StatelessWidget {
  const _VoiceNote({required this.onTap});
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blueprint.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_none, color: AppColors.blueprint),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grabar declaración por voz',
                      style: theme.textTheme.labelLarge),
                  Text('Audio opcional · máx 2 min',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _DanoInternoTile extends StatelessWidget {
  const _DanoInternoTile({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Sospechas daño interno?',
                    style: theme.textTheme.labelLarge),
                Text('Actívalo para una revisión mecánica',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.amber,
          ),
        ],
      ),
    );
  }
}
