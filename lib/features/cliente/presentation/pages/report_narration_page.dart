import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/report_controller.dart';
import '../widgets/report_step_header.dart';

class ReportNarrationPage extends ConsumerStatefulWidget {
  const ReportNarrationPage({super.key});

  @override
  ConsumerState<ReportNarrationPage> createState() =>
      _ReportNarrationPageState();
}

class _ReportNarrationPageState extends ConsumerState<ReportNarrationPage> {
  late final TextEditingController _narracion;
  final _recorder = AudioRecorder();
  bool _isRecording = false;
  int _recordedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _narracion =
        TextEditingController(text: ref.read(reportControllerProvider).narracionTexto);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
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

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _snack('Permiso de micrófono denegado.', color: AppColors.alert);
        return;
      }
      final dir = Directory.systemTemp;
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() => _isRecording = true);
      _recordedSeconds = 0;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _recordedSeconds++;
          if (_recordedSeconds >= 120) _stopRecording();
        });
      });
    } catch (e) {
      _snack('Error al iniciar grabación.', color: AppColors.alert);
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    setState(() => _isRecording = false);
    try {
      final path = await _recorder.stop();
      if (path == null) return;
      final file = File(path);
      if (!await file.exists()) return;
      final controller = ref.read(reportControllerProvider.notifier);
      controller.setAudioFile(file);
      controller.transcribirAudio();
      _snack('Audio enviado para transcripción…');
    } catch (e) {
      _snack('Error al detener grabación.', color: AppColors.alert);
    }
  }

  String get _timerText {
    final min = (_recordedSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_recordedSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
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
    final ok = await controller.crearSiniestro();
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

    if (state.transcripcion != null && _narracion.text != state.transcripcion) {
      _narracion.text = state.transcripcion!;
      _narracion.selection = TextSelection.fromPosition(
        TextPosition(offset: _narracion.text.length),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
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
                        color: context.textPrimaryColor,
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
                          ?.copyWith(color: context.textHintColor),
                      filled: true,
                      fillColor: context.surfaceColor,
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
                  _VoiceNote(
                    isRecording: _isRecording,
                    timerText: _timerText,
                    transcribiendo: state.transcribiendo,
                    transcripcion: state.transcripcion,
                    onTap: state.transcribiendo ? null : _toggleRecording,
                  ),
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
  const _VoiceNote({
    required this.isRecording,
    required this.timerText,
    required this.transcribiendo,
    required this.transcripcion,
    required this.onTap,
  });

  final bool isRecording;
  final String timerText;
  final bool transcribiendo;
  final String? transcripcion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isRecording ? AppColors.alert : context.borderColor,
            width: isRecording ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isRecording
                    ? AppColors.alert.withValues(alpha: 0.12)
                    : AppColors.blueprint.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: transcribiendo
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    )
                  : Icon(
                      isRecording ? Icons.stop : Icons.mic_none,
                      color: isRecording ? AppColors.alert : AppColors.blueprint,
                    ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transcribiendo
                        ? 'Transcribiendo…'
                        : isRecording
                            ? 'Grabando…'
                            : 'Grabar declaración por voz',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isRecording ? AppColors.alert : null,
                    ),
                  ),
                  Text(
                    transcripcion != null
                        ? 'Transcripción lista'
                        : transcribiendo
                            ? 'Procesando audio…'
                            : isRecording
                                ? timerText
                                : 'Audio opcional · máx 2 min',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (transcripcion != null)
              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else
              Icon(Icons.chevron_right, color: context.textHintColor),
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
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
