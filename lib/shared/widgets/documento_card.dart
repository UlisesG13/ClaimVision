import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/domain/models/documento.dart';

class DocumentoCard extends StatelessWidget {
  const DocumentoCard({
    super.key,
    required this.titulo,
    this.documento,
    this.numeroPoliza,
    this.vigencia,
    this.onVerCompleto,
    this.onReemplazar,
  });

  final String titulo;
  final DocumentoInfo? documento;
  final String? numeroPoliza;
  final String? vigencia;
  final VoidCallback? onVerCompleto;
  final VoidCallback? onReemplazar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                documento != null
                    ? (documento!.esPdf ? Icons.picture_as_pdf : Icons.image)
                    : Icons.description_outlined,
                color: documento != null
                    ? (documento!.esPdf ? AppColors.alert : AppColors.blueprint)
                    : context.textHintColor,
                size: 28,
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Text(
                  titulo,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (documento != null) ...[
            const Gap(AppSpacing.md),
            _InfoRow(
              label: 'Subido',
              value: _formatDate(documento!.subidoEn),
            ),
            if (numeroPoliza != null) ...[
              const Gap(AppSpacing.sm),
              _InfoRow(label: 'Póliza', value: numeroPoliza!),
            ],
            if (vigencia != null) ...[
              const Gap(AppSpacing.sm),
              _InfoRow(label: 'Vigencia', value: vigencia!),
            ],
            const Gap(AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onVerCompleto,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Ver documento completo'),
                  ),
                ),
                if (onReemplazar != null) ...[
                  const Gap(AppSpacing.sm),
                  TextButton(
                    onPressed: onReemplazar,
                    child: const Text('Reemplazar'),
                  ),
                ],
              ],
            ),
          ] else ...[
            const Gap(AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReemplazar,
                icon: const Icon(Icons.add, size: 18),
                label: Text('Subir $titulo'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')} ${_mes(d.month)} ${d.year}';
  }

  String _mes(int m) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return meses[m - 1];
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: context.textSecondaryColor)),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
