import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/cliente/presentation/state/providers.dart';

enum _DocumentType { identificacion, poliza }

class DocumentosUploadSheet extends ConsumerStatefulWidget {
  const DocumentosUploadSheet({super.key});

  @override
  ConsumerState<DocumentosUploadSheet> createState() =>
      _DocumentosUploadSheetState();
}

class _DocumentosUploadSheetState extends ConsumerState<DocumentosUploadSheet> {
  File? _identificacion;
  File? _poliza;
  bool _subiendo = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(top: false, child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.textHintColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(AppSpacing.lg),
          Text('Subir documentos',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(AppSpacing.md),
          _DocumentoPickerRow(
            label: 'Identificación oficial',
            archivo: _identificacion,
            onPick: () => _pickDocumento(_DocumentType.identificacion),
          ),
          const Gap(AppSpacing.md),
          _DocumentoPickerRow(
            label: 'Póliza del seguro',
            archivo: _poliza,
            onPick: () => _pickDocumento(_DocumentType.poliza),
          ),
          const Gap(AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _puedeSubir ? _subir : null,
              child: _subiendo
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Subir documentos'),
            ),
          ),
          const Gap(AppSpacing.md),
        ],
      ),
    ));
  }

  bool get _puedeSubir =>
      _identificacion != null && _poliza != null && !_subiendo;

  Future<void> _pickDocumento(_DocumentType tipo) async {
    if (tipo == _DocumentType.poliza) {
      final file = await ref.read(filePickerServiceProvider).pickPdf();
      if (file != null) setState(() => _poliza = file);
      return;
    }

    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => _SourceSheet(),
    );

    if (source == null) return;

    final imagePicker = ref.read(imagePickerServiceProvider);
    File? file;
    if (source == _PickSource.camera) {
      final picked = await imagePicker.fromCamera();
      if (picked != null) file = File(picked.path);
    } else if (source == _PickSource.gallery) {
      final picked = await imagePicker.fromGallery();
      if (picked != null) file = File(picked.path);
    } else {
      final picked = await ref.read(filePickerServiceProvider).pickPdf();
      if (picked != null) file = picked;
    }
    if (file != null) {
      setState(() => _identificacion = file);
    }
  }

  Future<void> _subir() async {
    final id = _identificacion;
    final pol = _poliza;
    if (id == null || pol == null) return;

    setState(() => _subiendo = true);
    try {
      await ref.read(documentoRepositoryProvider).subir(
            identificacion: id,
            poliza: pol,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documentos subidos correctamente')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }
}

enum _PickSource { camera, gallery, pdf }

class _SourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Seleccionar origen',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Gap(AppSpacing.md),
          _SourceOption(
            icon: Icons.camera_alt_outlined,
            label: 'Tomar foto',
            onTap: () => Navigator.pop(context, _PickSource.camera),
          ),
          _SourceOption(
            icon: Icons.photo_library_outlined,
            label: 'Subir desde galería',
            onTap: () => Navigator.pop(context, _PickSource.gallery),
          ),
          _SourceOption(
            icon: Icons.picture_as_pdf,
            label: 'Seleccionar PDF',
            onTap: () => Navigator.pop(context, _PickSource.pdf),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.blueprint),
      title: Text(label),
      trailing: Icon(Icons.chevron_right, color: context.textHintColor),
      onTap: onTap,
    );
  }
}

class _DocumentoPickerRow extends StatelessWidget {
  const _DocumentoPickerRow({
    required this.label,
    required this.archivo,
    required this.onPick,
  });
  final String label;
  final File? archivo;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: archivo != null ? AppColors.success : context.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              archivo != null
                  ? (archivo!.path.contains('.pdf')
                      ? Icons.picture_as_pdf
                      : Icons.image)
                  : Icons.upload_file,
              color: archivo != null ? AppColors.success : context.textHintColor,
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: Text(
                archivo != null
                    ? archivo!.path.split('\\').last.split('/').last
                    : label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: archivo != null
                      ? context.textPrimaryColor
                      : context.textSecondaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right,
                color: context.textHintColor, size: 20),
          ],
        ),
      ),
    );
  }
}
