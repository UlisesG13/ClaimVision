import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../ocr_controller.dart';

class OcrResultPage extends ConsumerWidget {
  const OcrResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ocrControllerProvider);
    final extraction = state.extraction;

    if (extraction == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBgColor,
        body: const Center(child: Text('No hay datos extraídos')),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        title: const Text('Datos extraídos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: AppColors.success),
          const Gap(AppSpacing.md),
          Text(
            'Extracción completada',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(4),
          Text(
            'Revisa que los datos sean correctos antes de confirmar.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpacing.xxl),
          if (extraction.nombre != null || extraction.curp != null) ...[
            _SectionHeader(title: 'INE'),
            _FieldCard(
              fields: [
                if (extraction.nombre != null)
                  _Field('Nombre', extraction.nombre!),
                if (extraction.curp != null)
                  _Field('CURP', extraction.curp!),
              ],
            ),
            const Gap(AppSpacing.lg),
          ],
          _SectionHeader(title: 'Póliza'),
          _FieldCard(
            fields: [
              if (extraction.numeroPoliza != null)
                _Field('Número de póliza', extraction.numeroPoliza!),
              if (extraction.aseguradora != null)
                _Field('Aseguradora', extraction.aseguradora!),
              if (extraction.vigenciaInicio != null)
                _Field('Vigencia inicio', extraction.vigenciaInicio!),
              if (extraction.vigenciaFin != null)
                _Field('Vigencia fin', extraction.vigenciaFin!),
            ],
          ),
          const Gap(AppSpacing.lg),
          _SectionHeader(title: 'Vehículo'),
          _FieldCard(
            fields: [
              if (extraction.marca != null)
                _Field('Marca', extraction.marca!),
              if (extraction.modelo != null)
                _Field('Modelo', extraction.modelo!),
              if (extraction.anio != null)
                _Field('Año', extraction.anio.toString()),
              if (extraction.placas != null)
                _Field('Placas', extraction.placas!),
            ],
          ),
          const Gap(AppSpacing.xxl),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: PrimaryButton(
          label: 'Datos correctos',
          icon: Icons.check,
          onPressed: () {
            AppSnackbar.success(context, 'Datos confirmados');
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.fields});

  final List<_Field> fields;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: fields.asMap().entries.map((entry) {
          final idx = entry.key;
          final field = entry.value;
          return Column(
            children: [
              if (idx > 0)
                Divider(height: 1, color: context.borderColor),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(field.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.textSecondaryColor)),
                    ),
                    Expanded(
                      child: Text(field.value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Field {
  const _Field(this.label, this.value);
  final String label;
  final String value;
}
