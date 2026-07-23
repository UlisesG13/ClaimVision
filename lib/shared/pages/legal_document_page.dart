import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/brand_app_bar.dart';

/// Página genérica para mostrar documentos legales (Aviso de Privacidad,
/// Términos y Condiciones). Accesible sin sesión desde el login y desde
/// Configuración. Respeta el tema claro/oscuro.
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.titulo,
    required this.contenido,
  });

  final String titulo;
  final String contenido;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: BrandAppBar(
        title: Text(
          titulo,
          style: theme.textTheme.titleLarge?.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(top: false, child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: context.borderColor),
          ),
          child: SelectableText(
            contenido.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      )),
    );
  }
}
