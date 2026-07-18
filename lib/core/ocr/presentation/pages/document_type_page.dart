import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/inline_banner.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/document_type.dart';
import '../ocr_controller.dart';
import 'document_capture_page.dart';

class DocumentTypePage extends ConsumerWidget {
  const DocumentTypePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ocrControllerProvider);
    final hasAll = state.hasAllRequired;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onBack: () => context.pushReplacement(RoutePaths.onboarding)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  Text(
                    'Captura de Documentos',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    'Toma o selecciona fotos de tus documentos para '
                    'vincular tu póliza.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                  ),
                  const Gap(AppSpacing.xl),
                  ...DocumentType.values.map(
                    (type) => _DocumentCard(
                      type: type,
                      capture: state.captureFor(type),
                      onTap: () => _openCapture(context, ref, type),
                    ),
                  ),
                  const Gap(AppSpacing.xl),
                  if (state.errorMessage != null)
                    InlineBanner(
                      kind: InlineBannerKind.error,
                      title: 'Error',
                      message: state.errorMessage!,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: state.loading
                    ? 'Procesando OCR...'
                    : 'Confirmar y vincular',
                isLoading: state.loading,
                onPressed: (!hasAll || state.loading || state.submitting)
                    ? null
                    : () => _submit(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCapture(BuildContext context, WidgetRef ref, DocumentType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentCapturePage(documentType: type),
      ),
    );
  }

  Future<void> _submit(WidgetRef ref) async {
    await ref.read(ocrControllerProvider.notifier).submitOcr();
    if (ref.read(ocrControllerProvider).extraction != null) {
      // Navigate to result page or back to onboarding with data
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surfaceColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.borderColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.arrow_back, size: 22),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Text('Documentos',
              style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.type,
    this.capture,
    required this.onTap,
  });

  final DocumentType type;
  final dynamic capture;
  final VoidCallback onTap;

  IconData get _icon {
    return switch (type) {
      DocumentType.ineFront || DocumentType.ineBack => Icons.badge_outlined,
      DocumentType.policy => Icons.description_outlined,
    };
  }

  Color get _statusColor {
    return capture != null ? AppColors.success : AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.scaffoldBgColor,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child:
                      Icon(_icon, size: 28, color: AppColors.blueprint),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const Gap(2),
                      Text(
                        capture != null
                            ? '${capture.quality.width}x${capture.quality.height}'
                            : type.hint,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.textHintColor),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle,
                    size: 22, color: _statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
