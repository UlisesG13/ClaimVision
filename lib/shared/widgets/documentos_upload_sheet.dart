import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/cliente/presentation/state/providers.dart';

class DocumentosUploadSheet extends ConsumerStatefulWidget {
  const DocumentosUploadSheet({super.key});

  @override
  ConsumerState<DocumentosUploadSheet> createState() =>
      _DocumentosUploadSheetState();
}

class _DocumentosUploadSheetState extends ConsumerState<DocumentosUploadSheet> {
  File? _identificacion;
  File? _identificacionReverso;
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
            label: 'INE Frente (PDF)',
            archivo: _identificacion,
            onPick: () => _pickPdf((f) => setState(() => _identificacion = f)),
          ),
          const Gap(AppSpacing.md),
          _DocumentoPickerRow(
            label: 'INE Reverso (PDF)',
            archivo: _identificacionReverso,
            onPick: () => _pickPdf((f) => setState(() => _identificacionReverso = f)),
          ),
          const Gap(AppSpacing.md),
          _DocumentoPickerRow(
            label: 'Póliza del seguro',
            archivo: _poliza,
            onPick: () => _pickPdf((f) => setState(() => _poliza = f)),
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
      _identificacion != null && _identificacionReverso != null && _poliza != null && !_subiendo;

  Future<void> _pickPdf(void Function(File) onSelected) async {
    final file = await ref.read(filePickerServiceProvider).pickPdf();
    if (file != null) onSelected(file);
  }

  Future<void> _subir() async {
    final id = _identificacion;
    final idRev = _identificacionReverso;
    final pol = _poliza;
    if (id == null || idRev == null || pol == null) return;

    setState(() => _subiendo = true);
    try {
      await ref.read(documentoRepositoryProvider).subir(
            identificacion: id,
            identificacionReverso: idRev,
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
              archivo != null ? Icons.picture_as_pdf : Icons.upload_file,
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
