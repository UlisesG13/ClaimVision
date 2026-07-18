import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/feedback/inline_banner.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/document_type.dart';
import '../../domain/image_quality.dart';
import '../ocr_controller.dart';
import '../widgets/capture_overlay.dart';
import '../widgets/validation_indicator.dart';

class DocumentCapturePage extends ConsumerStatefulWidget {
  const DocumentCapturePage({super.key, required this.documentType});

  final DocumentType documentType;

  @override
  ConsumerState<DocumentCapturePage> createState() =>
      _DocumentCapturePageState();
}

class _DocumentCapturePageState extends ConsumerState<DocumentCapturePage> {
  File? _imageFile;
  ImageQuality? _quality;
  bool _validating = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _imageFile = null;
      _quality = null;
    });

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
    );

    if (xFile == null) return;

    final file = File(xFile.path);
    setState(() => _validating = true);

    try {
      final validator = ref.read(imageValidatorProvider);
      final quality = await validator.validate(file, widget.documentType);
      setState(() {
        _imageFile = file;
        _quality = quality;
        _validating = false;
      });

      if (quality.passesMinimum && mounted) {
        AppSnackbar.success(context, 'Imagen capturada correctamente');
      }
    } catch (_) {
      setState(() => _validating = false);
      if (mounted) {
        AppSnackbar.error(context, 'Error al validar la imagen');
      }
    }
  }

  void _confirm() {
    if (_imageFile == null || _quality == null) return;

    ref.read(ocrControllerProvider.notifier).addCapture(
          OcrCapture(
            type: widget.documentType,
            file: _imageFile!,
            quality: _quality!,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: Text(widget.documentType.label),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_imageFile != null)
                    Image.file(_imageFile!, fit: BoxFit.contain)
                  else
                    Container(
                      color: Colors.grey.shade900,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 64, color: Colors.grey.shade600),
                            const Gap(AppSpacing.md),
                            Text(
                              'Toma o selecciona una foto',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  CaptureOverlay(
                    type: widget.documentType,
                    hasImage: _imageFile != null,
                  ),
                ],
              ),
            ),
            if (_validating)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.amber),
                ),
              )
            else ...[
              if (_quality != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: ValidationIndicator(
                    quality: _quality!,
                    type: widget.documentType,
                  ),
                ),
              if (_imageFile == null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: InlineBanner(
                    kind: InlineBannerKind.info,
                    title: 'Consejo',
                    message: 'Coloca el documento dentro del marco '
                        'con buena iluminación y sin reflejos.',
                  ),
                ),
              Container(
                color: Colors.grey.shade900,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galería'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                      ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _imageFile != null
                            ? 'Tomar otra'
                            : 'Tomar foto',
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
                  child: PrimaryButton(
                    label: 'Confirmar',
                    icon: Icons.check,
                    onPressed: _quality?.passesMinimum == true
                        ? _confirm
                        : null,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
