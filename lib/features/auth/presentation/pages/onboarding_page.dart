import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
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

  @override
  void dispose() {
    _numeroController.dispose();
    _vigenciaController.dispose();
    _curpController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument({required bool isCedula}) async {
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => const _SourceSheet(),
    );
    if (source == null) return;

    final picker = ref.read(imagePickerServiceProvider);
    final File? file = source == _PickSource.camera
        ? await picker.fromCamera()
        : await picker.fromGallery();
    if (file == null) return;

    final controller = ref.read(onboardingControllerProvider.notifier);
    if (isCedula) {
      controller.setCedula(file);
    } else {
      controller.setPoliza(file);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onBack: () {
              if (context.canPop()) context.pop();
            }),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ScanStatusCard(
                      ocrLoading: state.ocrLoading,
                      hasDetected: state.hasDetected,
                    ),
                    const Gap(AppSpacing.lg),
                    _DocumentSlot(
                      label: 'Cédula / Identificación',
                      file: state.cedula,
                      onTap: () => _pickDocument(isCedula: true),
                    ),
                    const Gap(AppSpacing.md),
                    _DocumentSlot(
                      label: 'Póliza del seguro',
                      file: state.poliza,
                      onTap: () => _pickDocument(isCedula: false),
                    ),
                    const Gap(AppSpacing.lg),
                    if (!state.hasDetected)
                      PrimaryButton(
                        label: 'Analizar documentos',
                        icon: Icons.document_scanner_outlined,
                        isLoading: state.ocrLoading,
                        onPressed:
                            state.hasBothImages ? controller.runOcr : null,
                        foregroundColor: const Color(0xFF6D4400),
                      ),
                    if (state.hasDetected) ...[
                      _DetectedDataCard(
                        numeroController: _numeroController,
                        vigenciaController: _vigenciaController,
                        curpController: _curpController,
                        onNumero: controller.editNumeroPoliza,
                        onVigencia: controller.editVigencia,
                        onCurp: controller.editCurpRfc,
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
                      if (!state.avisoPrivacidad)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            'Debes aceptar el Aviso de Privacidad para continuar.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
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

enum _PickSource { camera, gallery }

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 84,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.arrow_back,
                  size: 20, color: AppColors.textPrimary),
            ),
          ),
          const Gap(AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Vincula tu Póliza', style: theme.textTheme.titleLarge),
              Text('Paso 1 de 2', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanStatusCard extends StatelessWidget {
  const _ScanStatusCard({required this.ocrLoading, required this.hasDetected});
  final bool ocrLoading;
  final bool hasDetected;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String text) = switch ((ocrLoading, hasDetected)) {
      (true, _) => (
          Icons.document_scanner_outlined,
          'Analizando tus documentos…'
        ),
      (_, true) => (Icons.check_circle_outline, 'Documentos analizados'),
      _ => (Icons.qr_code_scanner, 'Agrega tus documentos para comenzar'),
    };
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF000616),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (ocrLoading)
            const CircularProgressIndicator(color: AppColors.amber)
          else
            Icon(icon, size: 48, color: AppColors.amber),
          const Gap(AppSpacing.md),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB4C7EC),
                ),
          ),
        ],
      ),
    );
  }
}

class _DocumentSlot extends StatelessWidget {
  const _DocumentSlot(
      {required this.label, required this.file, required this.onTap});
  final String label;
  final File? file;
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: const Color(0xFFE5E8EB), width: 1.2),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: hasFile
                  ? Image.file(file!, width: 44, height: 44, fit: BoxFit.cover)
                  : Container(
                      width: 44,
                      height: 44,
                      color: AppColors.background,
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
                    hasFile
                        ? 'Documento agregado'
                        : 'Toca para agregar (cámara o galería)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.check_circle : Icons.add_circle_outline,
              color: hasFile ? AppColors.success : AppColors.textSecondary,
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
    required this.onNumero,
    required this.onVigencia,
    required this.onCurp,
  });

  final TextEditingController numeroController;
  final TextEditingController vigenciaController;
  final TextEditingController curpController;
  final ValueChanged<String> onNumero;
  final ValueChanged<String> onVigencia;
  final ValueChanged<String> onCurp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          color: AppColors.white,
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
          const Gap(AppSpacing.sm),
        ],
      ),
    );
  }
}
