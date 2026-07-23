import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/failures.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/cliente/presentation/state/providers.dart';
import '../../shared/domain/models/documento.dart';
import '../widgets/brand_app_bar.dart';
import '../widgets/documento_card.dart';
import '../widgets/documentos_upload_sheet.dart';
import 'document_viewer_page.dart';

class DocumentosPage extends ConsumerWidget {
  const DocumentosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentos = ref.watch(documentosProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: BrandAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text('Mis Documentos',
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SafeArea(top: false, child: documentos.when(
        loading: () => const _ShimmerList(),
        error: (err, _) => _ErrorState(
          message: err is Failure ? err.message : 'Error al cargar documentos',
          onRetry: () => ref.invalidate(documentosProvider),
        ),
        data: (data) => _DocumentosContent(
          data: data,
          onUploadComplete: () => ref.invalidate(documentosProvider),
        ),
      ),
      ),
    );
  }
}

class _DocumentosContent extends StatelessWidget {
  const _DocumentosContent({
    required this.data,
    required this.onUploadComplete,
  });
  final DocumentosResponse data;
  final VoidCallback onUploadComplete;

  @override
  Widget build(BuildContext context) {
    if (!data.hayDocumentos) {
      return _EmptyState(onUpload: () => _abrirUpload(context));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        DocumentoCard(
          titulo: 'Identificación Oficial',
          documento: data.identificacion,
          onVerCompleto: data.identificacion != null
              ? () => _verCompleto(context, 'Identificación Oficial',
                  data.identificacion!)
              : null,
          onReemplazar: () => _abrirUpload(context),
        ),
        const Gap(AppSpacing.lg),
        DocumentoCard(
          titulo: 'Póliza del Seguro',
          documento: data.poliza,
          numeroPoliza: data.numeroPoliza,
          vigencia: data.vigencia,
          onVerCompleto: data.poliza != null
              ? () => _verCompleto(
                    context,
                    'Póliza del Seguro',
                    data.poliza!,
                  )
              : null,
          onReemplazar: () => _abrirUpload(context),
        ),
        const Gap(AppSpacing.xl),
        Center(
          child: TextButton.icon(
            onPressed: () => _abrirUpload(context),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reemplazar documentos'),
          ),
        ),
      ],
    );
  }

  void _abrirUpload(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => const DocumentosUploadSheet(),
    );
    if (result == true) onUploadComplete();
  }

  void _verCompleto(BuildContext context, String titulo, DocumentoInfo doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerPage(titulo: titulo, documento: doc),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onUpload});
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined,
                size: 80, color: context.textHintColor.withValues(alpha: 0.5)),
            const Gap(AppSpacing.lg),
            Text('Aún no has subido documentos',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Gap(AppSpacing.sm),
            Text(
              'Sube tu identificación oficial y póliza del seguro para tenerlas siempre disponibles.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.textSecondaryColor),
            ),
            const Gap(AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Subir documentos ahora'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueprint,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 64, color: AppColors.alert.withValues(alpha: 0.6)),
            const Gap(AppSpacing.md),
            Text(message, textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium),
            const Gap(AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: context.borderColor),
            ),
          ),
        ),
      ),
    );
  }
}
