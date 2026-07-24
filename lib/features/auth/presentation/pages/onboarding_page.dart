import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/services/screenshot_protection_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/feedback/inline_banner.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/onboarding_controller.dart';

/// Onboarding del cliente — "Vincula tu Póliza" (Figma node 70:284).
///
/// El cliente sube su cédula y póliza → OCR (`/cliente/onboarding/ocr`),
/// revisa/edita los datos, otorga los consentimientos ARCO
/// (`/auth/consentimiento`) y confirma (`/cliente/onboarding/confirmar-datos`).
/// El Aviso de Privacidad es un gate obligatorio para poder confirmar.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _numeroController = TextEditingController();
  final _vigenciaController = TextEditingController();
  final _curpController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _placasController = TextEditingController();
  final _screenshotProtection = ScreenshotProtectionService();
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    _screenshotProtection.enable();
  }

  @override
  void dispose() {
    _screenshotProtection.disable();
    _numeroController.dispose();
    _vigenciaController.dispose();
    _curpController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _placasController.dispose();
    super.dispose();
  }

  Future<void> _pickInes() async {
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => const _SourceSheet(),
    );
    if (source == null) return;

    if (source == _PickSource.pdf) {
      final file = await ref.read(filePickerServiceProvider).pickPdf();
      if (file != null) {
        ref.read(onboardingControllerProvider.notifier).setIdentificacion(file);
      }
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      final picker = ref.read(imagePickerServiceProvider);
      File frente;
      File reverso;

      if (source == _PickSource.camera) {
        final f = await picker.fromCamera();
        if (f == null) return;
        frente = f;

        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('INE Reverso'),
            content: const Text('Ahora toma la foto del reverso de tu INE.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        final r = await picker.fromCamera();
        if (r == null) return;
        reverso = r;
      } else {
        final images = await picker.pickMultipleFromGallery();
        if (images.length < 2) {
          if (mounted) {
            AppSnackbar.error(context, 'Selecciona ambas caras de la INE (frente y reverso).');
          }
          return;
        }
        frente = images[0];
        reverso = images[1];
      }

      if (!mounted) return;
      final pdf = await ref.read(inePdfServiceProvider).combine(
            frente: frente,
            reverso: reverso,
          );
      if (!mounted) return;
      ref.read(onboardingControllerProvider.notifier).setIdentificacion(pdf);
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error al procesar las imágenes.');
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  /// Póliza: siempre se envía como PDF (requisito del backend). El usuario puede
  /// cargar el PDF digital del asegurador, o fotografiarla y la envolvemos en un
  /// PDF de 1 página.
  Future<void> _pickPoliza() async {
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => const _SourceSheet(),
    );
    if (source == null) return;

    if (source == _PickSource.pdf) {
      final file = await ref.read(filePickerServiceProvider).pickPdf();
      if (file != null) {
        ref.read(onboardingControllerProvider.notifier).setPoliza(file);
      }
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      final picker = ref.read(imagePickerServiceProvider);
      final foto = source == _PickSource.camera
          ? await picker.fromCamera()
          : await picker.fromGallery();
      if (foto == null) return;

      final pdf = await ref.read(inePdfServiceProvider).fromImage(foto);
      if (!mounted) return;
      ref.read(onboardingControllerProvider.notifier).setPoliza(pdf);
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Error al procesar la foto de la póliza.');
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    // Rellena los campos editables cuando el OCR termina.
    ref.listen(
      onboardingControllerProvider.select((s) => s.hasDetected),
      (prev, hasDetected) {
        if (hasDetected == true && prev != true) {
          final s = ref.read(onboardingControllerProvider);
          _numeroController.text = s.numeroPoliza;
          _vigenciaController.text = s.vigenciaPoliza;
          _curpController.text = s.curpRfc;
          _marcaController.text = s.vehiculoMarca;
          _modeloController.text = s.vehiculoModelo;
          _anioController.text = s.vehiculoAnio;
          _placasController.text = s.vehiculoPlacas;
        }
      },
    );

    // Errores → SnackBar.
    ref.listen(
      onboardingControllerProvider.select((s) => s.errorMessage),
      (prev, message) {
        if (message != null && message.isNotEmpty) {
          AppSnackbar.error(context, message);
        }
      },
    );

    // Onboarding completado → ir al inicio del cliente.
    ref.listen(
      onboardingControllerProvider.select((s) => s.completed),
      (prev, completed) {
        if (completed == true && prev != true) {
          AppSnackbar.success(context, 'Póliza vinculada correctamente.');
          context.go(RoutePaths.inicio);
        }
      },
    );

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScanStatusCard(
                      ocrLoading: state.ocrLoading,
                      generatingPdf: _generatingPdf,
                      hasDetected: state.hasDetected,
                    ),
                    const Gap(AppSpacing.lg),
                    _DocumentSlot(
                      label: 'INE (Frente y Reverso)',
                      file: state.cedula,
                      isPdf: true,
                      hint: 'Toca para capturar o seleccionar ambas caras',
                      onTap: _pickInes,
                    ),
                    const Gap(AppSpacing.md),
                    _DocumentSlot(
                      label: 'Póliza del seguro',
                      file: state.poliza,
                      isPdf: true,
                      hint: 'Toca para capturar, elegir de galería o subir PDF',
                      onTap: _pickPoliza,
                    ),
                    const Gap(AppSpacing.lg),
                    if (!state.hasDetected)
                      PrimaryButton(
                        label: 'Analizar documentos',
                        icon: Icons.document_scanner_outlined,
                        isLoading: state.ocrLoading,
                        onPressed:
                            state.hasRequiredDocuments ? controller.runOcr : null,
                        foregroundColor: const Color(0xFF6D4400),
                      ),
                    if (state.hasDetected) ...[
                      _DetectedDataCard(
                        numeroController: _numeroController,
                        vigenciaController: _vigenciaController,
                        curpController: _curpController,
                        marcaController: _marcaController,
                        modeloController: _modeloController,
                        anioController: _anioController,
                        placasController: _placasController,
                        aseguradora: state.aseguradora,
                        nombreAsegurado: state.nombreAsegurado,
                        onNumero: controller.editNumeroPoliza,
                        onVigencia: controller.editVigencia,
                        onCurp: controller.editCurpRfc,
                        onMarca: controller.editVehiculoMarca,
                        onModelo: controller.editVehiculoModelo,
                        onAnio: controller.editVehiculoAnio,
                        onPlacas: controller.editVehiculoPlacas,
                      ),
                      const Gap(AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: state.submitting
                            ? null
                            : controller.reiniciarDocumentos,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Volver a añadir documentos'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.blueprint,
                          side: BorderSide(
                              color: AppColors.blueprint.withValues(alpha: 0.4)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      const InlineBanner(
                        kind: InlineBannerKind.security,
                        title: 'Datos cifrados',
                        message: 'Tu información se protege con AES-256-GCM.',
                      ),
                      const Gap(AppSpacing.lg),
                      Text(
                        'Consentimientos (ARCO)',
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                      ),
                      const Gap(AppSpacing.md),
                      _ConsentRow(
                        label: 'Acepto el Aviso de Privacidad',
                        value: state.avisoPrivacidad,
                        onChanged: controller.toggleAviso,
                      ),
                      const Gap(AppSpacing.sm),
                      _ConsentRow(
                        label: 'Autorizo el uso de datos biométricos',
                        value: state.biometria,
                        onChanged: controller.toggleBiometria,
                      ),
                      const Gap(AppSpacing.sm),
                      _ConsentRow(
                        label: 'Autorizo transferencia a talleres',
                        value: state.transferenciaTalleres,
                        onChanged: controller.toggleTransferencia,
                      ),
                      const Gap(AppSpacing.xl),
                      PrimaryButton(
                        label: 'Confirmar y Vincular',
                        icon: Icons.verified_outlined,
                        isLoading: state.submitting,
                        onPressed: state.canConfirm ? controller.confirm : null,
                        foregroundColor: const Color(0xFF6D4400),
                      ),
                      if (!state.canConfirm && !state.submitting)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            'Completa para continuar: '
                            '${state.missingToConfirm.join(', ')}.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.alert,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PickSource { camera, gallery, pdf }

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined,
                color: AppColors.blueprint),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.pop(context, _PickSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: AppColors.blueprint),
            title: const Text('Subir desde galería'),
            onTap: () => Navigator.pop(context, _PickSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.blueprint),
            title: const Text('Seleccionar PDF'),
            onTap: () => Navigator.pop(context, _PickSource.pdf),
          ),
          const Gap(AppSpacing.sm),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 84,
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Vincula tu Póliza', style: theme.textTheme.titleLarge),
          Text('Paso 1 de 2', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ScanStatusCard extends StatefulWidget {
  const _ScanStatusCard({
    required this.ocrLoading,
    required this.generatingPdf,
    required this.hasDetected,
  });
  final bool ocrLoading;
  final bool generatingPdf;
  final bool hasDetected;

  @override
  State<_ScanStatusCard> createState() => _ScanStatusCardState();
}

class _ScanStatusCardState extends State<_ScanStatusCard>
    with SingleTickerProviderStateMixin {
  static const _steps = <String>[
    'Leyendo tu INE…',
    'Extrayendo datos de la póliza…',
    'Validando la calidad de las imágenes…',
    'Verificando número de póliza y vigencia…',
    'Cruzando datos de INE y póliza…',
    'Casi listo…',
  ];

  late final AnimationController _progress;
  Timer? _cycler;
  int _step = 0;

  bool get _analyzing => widget.ocrLoading;

  @override
  void initState() {
    super.initState();
    // Progreso "simulado": avanza hacia ~92% mientras esperamos la respuesta y
    // se completa al terminar. El OCR es una sola llamada sin progreso real.
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    if (_analyzing) _startAnalyzing();
  }

  @override
  void didUpdateWidget(covariant _ScanStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_analyzing && !oldWidget.ocrLoading) {
      _startAnalyzing();
    } else if (!_analyzing && oldWidget.ocrLoading) {
      _stopAnalyzing(completed: widget.hasDetected);
    }
  }

  void _startAnalyzing() {
    _step = 0;
    _progress
      ..reset()
      ..forward();
    _cycler?.cancel();
    _cycler = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (!mounted) return;
      setState(() => _step = (_step + 1) % _steps.length);
    });
  }

  void _stopAnalyzing({required bool completed}) {
    _cycler?.cancel();
    _cycler = null;
    if (completed) {
      _progress.animateTo(1, duration: const Duration(milliseconds: 400));
    } else {
      _progress.stop();
    }
  }

  @override
  void dispose() {
    _cycler?.cancel();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFB4C7EC),
        );

    return Container(
      height: 170,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFF000616),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.generatingPdf) ...[
            const Icon(Icons.picture_as_pdf, size: 44, color: AppColors.amber),
            const Gap(AppSpacing.md),
            Text('Generando PDF de la INE…',
                textAlign: TextAlign.center, style: textStyle),
            const Gap(AppSpacing.md),
            _bar(null),
          ] else if (_analyzing) ...[
            const Icon(Icons.document_scanner_outlined,
                size: 44, color: AppColors.amber),
            const Gap(AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Text(
                _steps[_step],
                key: ValueKey(_step),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
            const Gap(AppSpacing.md),
            AnimatedBuilder(
              animation: _progress,
              builder: (_, _) {
                final value = Curves.easeOut.transform(_progress.value) * 0.92;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _bar(value),
                    const Gap(AppSpacing.xs),
                    Text('${(value * 100).round()}%',
                        textAlign: TextAlign.right,
                        style: textStyle?.copyWith(fontSize: 11)),
                  ],
                );
              },
            ),
          ] else if (widget.hasDetected) ...[
            const Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.amber),
            const Gap(AppSpacing.md),
            Text('Documentos analizados',
                textAlign: TextAlign.center, style: textStyle),
          ] else ...[
            const Icon(Icons.qr_code_scanner, size: 48, color: AppColors.amber),
            const Gap(AppSpacing.md),
            Text('Agrega tus documentos para comenzar',
                textAlign: TextAlign.center, style: textStyle),
          ],
        ],
      ),
    );
  }

  Widget _bar(double? value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: const Color(0xFF1B2440),
        valueColor: const AlwaysStoppedAnimation(AppColors.amber),
      ),
    );
  }
}

class _DocumentSlot extends StatelessWidget {
  const _DocumentSlot({
    required this.label,
    required this.file,
    required this.isPdf,
    required this.hint,
    required this.onTap,
  });
  final String label;
  final File? file;
  final bool isPdf;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = file != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: const Color(0xFFE5E8EB), width: 1.2),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: hasFile
                  ? (isPdf
                      ? Container(
                          width: 44,
                          height: 44,
                          color: AppColors.alert.withValues(alpha: 0.1),
                          child: const Icon(Icons.picture_as_pdf,
                              color: AppColors.alert, size: 28),
                        )
                      : Image.file(file!,
                          width: 44, height: 44, fit: BoxFit.cover))
                  : Container(
                      width: 44,
                      height: 44,
                      color: context.scaffoldBgColor,
                      child: const Icon(Icons.description_outlined,
                          color: AppColors.blueprint),
                    ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelLarge),
                  Text(
                    hasFile ? 'Documento agregado' : hint,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.check_circle : Icons.add_circle_outline,
              color: hasFile ? AppColors.success : context.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectedDataCard extends StatelessWidget {
  const _DetectedDataCard({
    required this.numeroController,
    required this.vigenciaController,
    required this.curpController,
    required this.marcaController,
    required this.modeloController,
    required this.anioController,
    required this.placasController,
    required this.aseguradora,
    required this.nombreAsegurado,
    required this.onNumero,
    required this.onVigencia,
    required this.onCurp,
    required this.onMarca,
    required this.onModelo,
    required this.onAnio,
    required this.onPlacas,
  });

  final TextEditingController numeroController;
  final TextEditingController vigenciaController;
  final TextEditingController curpController;
  final TextEditingController marcaController;
  final TextEditingController modeloController;
  final TextEditingController anioController;
  final TextEditingController placasController;
  final String aseguradora;
  final String nombreAsegurado;
  final ValueChanged<String> onNumero;
  final ValueChanged<String> onVigencia;
  final ValueChanged<String> onCurp;
  final ValueChanged<String> onMarca;
  final ValueChanged<String> onModelo;
  final ValueChanged<String> onAnio;
  final ValueChanged<String> onPlacas;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: const Color(0xFFE5E8EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Datos detectados',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
          const Gap(AppSpacing.xs),
          Text('Revisa y corrige si es necesario.',
              style: theme.textTheme.bodySmall),
          if (aseguradora.isNotEmpty || nombreAsegurado.isNotEmpty) ...[
            const Gap(AppSpacing.md),
            if (aseguradora.isNotEmpty)
              _ReadOnlyRow(label: 'Aseguradora', value: aseguradora),
            if (nombreAsegurado.isNotEmpty)
              _ReadOnlyRow(label: 'Asegurado', value: nombreAsegurado),
          ],
          const Gap(AppSpacing.md),
          _Field(
              label: 'Número de Póliza',
              controller: numeroController,
              onChanged: onNumero),
          const Gap(AppSpacing.sm),
          _Field(
              label: 'Vigencia (AAAA-MM-DD)',
              controller: vigenciaController,
              onChanged: onVigencia),
          const Gap(AppSpacing.sm),
          _Field(
              label: 'CURP / RFC',
              controller: curpController,
              onChanged: onCurp),
          const Gap(AppSpacing.md),
          Text('Vehículo asegurado',
              style: theme.textTheme.labelLarge),
          const Gap(AppSpacing.sm),
          _Field(
              label: 'Marca',
              controller: marcaController,
              onChanged: onMarca),
          const Gap(AppSpacing.sm),
          _Field(
              label: 'Modelo',
              controller: modeloController,
              onChanged: onModelo),
          const Gap(AppSpacing.sm),
          _Field(
              label: 'Año',
              controller: anioController,
              onChanged: onAnio),
          const Gap(AppSpacing.sm),
          _Field(
              label: 'Placas',
              controller: placasController,
              onChanged: onPlacas),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.label, required this.controller, required this.onChanged});
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(labelText: label, isDense: true),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: const Color(0xFFE5E8EB)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF009A60) : AppColors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color:
                      value ? const Color(0xFF009A60) : const Color(0xFFE5E8EB),
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: AppColors.white)
                  : null,
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}


