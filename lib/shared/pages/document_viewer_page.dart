import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/domain/models/documento.dart';
import '../widgets/brand_app_bar.dart';

class DocumentViewerPage extends StatelessWidget {
  const DocumentViewerPage({
    super.key,
    required this.titulo,
    required this.documento,
  });

  final String titulo;
  final DocumentoInfo documento;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: BrandAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(titulo,
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: SafeArea(top: false, child: documento.esPdf ? _buildPdfView(context) : _buildImageView(context)),
    );
  }

  Widget _buildPdfView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 96,
              color: AppColors.alert.withValues(alpha: 0.7),
            ),
            const Gap(AppSpacing.lg),
            Text(
              titulo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(AppSpacing.md),
            Text(
              'Este documento es un PDF. Ábrelo en tu navegador para verlo completo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.textSecondaryColor),
            ),
            const Gap(AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _abrirUrl(context),
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Abrir en navegador'),
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

  Widget _buildImageView(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        child: Image.network(
          documento.url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (_, _, _) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image, size: 64),
                Text('No se pudo cargar la imagen'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirUrl(BuildContext context) async {
    final uri = Uri.parse(documento.url);
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }
}
