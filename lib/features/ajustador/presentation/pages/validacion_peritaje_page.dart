import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/feedback/app_toast.dart';
import '../../domain/entities/damage_adjusted.dart';
import '../../domain/entities/damage_severity.dart';
import '../../domain/entities/damage_type.dart';
import '../state/casos_asignados_controller.dart';
import '../state/peritaje_editor_controller.dart';

/// Validación de Peritaje (Figma node 76:4615).
///
/// El ajustador registra y ajusta los daños (zona, tipo, severidad, costo) y
/// observaciones. El costo definitivo se autosuma (editable). Continúa a la
/// firma. Todo se guarda en el borrador [peritajeEditorControllerProvider].
class ValidacionPeritajePage extends ConsumerWidget {
  const ValidacionPeritajePage({super.key, required this.siniestroId});

  final String siniestroId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(peritajeEditorControllerProvider);
    final controller = ref.read(peritajeEditorControllerProvider.notifier);
    final casosAsync = ref.watch(casosAsignadosControllerProvider);
    final Siniestro? siniestro = casosAsync.asData?.value
        .where((s) => s.id == siniestroId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        title: Text('Validación de Peritaje', style: theme.textTheme.titleLarge),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl,
            AppSpacing.xl + MediaQuery.viewPaddingOf(context).bottom),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: state.tieneDanos
                ? () => context.push(RoutePaths.firmaPeritajeDe(siniestroId))
                : null,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Continuar a firma'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: AppColors.blueprint,
              disabledBackgroundColor: AppColors.amber.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(top: false, child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text('Ajusta los daños detectados',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.xs),
          Text(
            'Registra cada daño con su zona, tipo, severidad y costo de reparación.',
            style: theme.textTheme.bodySmall,
          ),
          const Gap(AppSpacing.lg),
          if (siniestro != null)
            _MiniMapLink(
              latitud: siniestro.latitud,
              longitud: siniestro.longitud,
            ),
          const Gap(AppSpacing.lg),
          if (state.danos.isEmpty)
            _SinDanos()
          else
            for (var i = 0; i < state.danos.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _DanoCard(
                  dano: state.danos[i],
                  onEditar: () async {
                    final editado = await _editarDano(context, state.danos[i]);
                    if (editado != null) controller.actualizarDano(i, editado);
                  },
                  onQuitar: () {
                    final eliminado = state.danos[i];
                    controller.quitarDano(i);
                    AppSnackbar.show(
                      context,
                      'Daño eliminado',
                      actionLabel: 'DESHACER',
                      onAction: () => controller.agregarDano(eliminado),
                    );
                  },
                ),
              ),
          const Gap(AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final nuevo = await _editarDano(context, null);
                if (nuevo != null && context.mounted) {
                  controller.agregarDano(nuevo);
                  AppToast.success(context, 'Daño agregado');
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar daño'),
            ),
          ),
          const Gap(AppSpacing.lg),
          Text('Observaciones de campo',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500, color: context.textPrimaryColor)),
          const Gap(AppSpacing.sm),
          TextFormField(
            initialValue: state.observaciones,
            maxLines: 3,
            onChanged: controller.setObservaciones,
            decoration: InputDecoration(
              hintText: 'Notas del peritaje (opcional)…',
              filled: true,
              fillColor: context.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: const BorderSide(color: Color(0xFFC4C6CE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: const BorderSide(color: Color(0xFFC4C6CE)),
              ),
            ),
          ),
          const Gap(AppSpacing.lg),
          _CostoCard(
            sugerido: state.costoSugerido,
            definitivo: state.costoDefinitivo,
            esManual: state.costoOverride != null,
            onEditar: () async {
              final nuevo = await _editarCosto(context, state.costoDefinitivo);
              if (nuevo != null) controller.setCostoDefinitivo(nuevo);
            },
            onAuto: () => controller.setCostoDefinitivo(null),
          ),
        ],
      ),
    ));
  }

  /// Bottom sheet para crear/editar un daño. Devuelve `null` si se cancela.
  Future<DamageAdjusted?> _editarDano(
      BuildContext context, DamageAdjusted? inicial) {
    return showModalBottomSheet<DamageAdjusted>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DanoForm(inicial: inicial),
    );
  }

  Future<double?> _editarCosto(BuildContext context, double actual) {
    final controller = TextEditingController(text: actual.toStringAsFixed(0));
    return showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Costo definitivo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(prefixText: '\$ '),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(
                context, double.tryParse(controller.text.trim())),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

String _money(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '\$$buf';
}

class _DanoCard extends StatelessWidget {
  const _DanoCard(
      {required this.dano, required this.onEditar, required this.onQuitar});
  final DamageAdjusted dano;
  final VoidCallback onEditar;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sevColor = switch (dano.severidad) {
      DamageSeverity.bajo => AppColors.success,
      DamageSeverity.medio => AppColors.amber,
      DamageSeverity.alto => AppColors.alert,
    };
    return Container(
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
              Expanded(
                child: Text(dano.zonaVehiculo,
                    style:
                        theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(dano.severidad.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: sevColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          Text(dano.tipo.label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.textSecondaryColor)),
          const Gap(AppSpacing.sm),
          Row(
            children: [
              Text('Costo real: ${_money(dano.costoRealReparacion)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.blueprint,
              ),
              IconButton(
                onPressed: onQuitar,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.alert,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostoCard extends StatelessWidget {
  const _CostoCard({
    required this.sugerido,
    required this.definitivo,
    required this.esManual,
    required this.onEditar,
    required this.onAuto,
  });
  final double sugerido;
  final double definitivo;
  final bool esManual;
  final VoidCallback onEditar;
  final VoidCallback onAuto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blueprint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Costo definitivo del peritaje',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFFB4C7EC))),
          const Gap(AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_money(definitivo),
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: AppColors.white, fontSize: 28)),
              const Spacer(),
              TextButton(
                onPressed: onEditar,
                style: TextButton.styleFrom(foregroundColor: AppColors.amber),
                child: const Text('Editar'),
              ),
            ],
          ),
          if (esManual)
            Row(
              children: [
                Text('Suma de daños: ${_money(sugerido)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFFB4C7EC))),
                const Spacer(),
                TextButton(
                  onPressed: onAuto,
                  style: TextButton.styleFrom(foregroundColor: AppColors.white),
                  child: const Text('Usar suma'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SinDanos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.add_road, size: 36, color: context.textHintColor),
          const Gap(AppSpacing.sm),
          Text('Agrega los daños del vehículo',
              style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Formulario (bottom sheet) para crear/editar un daño.
class _DanoForm extends StatefulWidget {
  const _DanoForm({this.inicial});
  final DamageAdjusted? inicial;

  @override
  State<_DanoForm> createState() => _DanoFormState();
}

class _DanoFormState extends State<_DanoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _zona;
  late final TextEditingController _costo;
  late DamageType _tipo;
  late DamageSeverity _severidad;

  @override
  void initState() {
    super.initState();
    final d = widget.inicial;
    _zona = TextEditingController(text: d?.zonaVehiculo ?? '');
    _costo = TextEditingController(
        text: d != null ? d.costoRealReparacion.toStringAsFixed(0) : '');
    _tipo = d?.tipo ?? DamageType.abolladura;
    _severidad = d?.severidad ?? DamageSeverity.medio;
  }

  @override
  void dispose() {
    _zona.dispose();
    _costo.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      DamageAdjusted(
        id: widget.inicial?.id,
        zonaVehiculo: _zona.text.trim(),
        tipo: _tipo,
        severidad: _severidad,
        costoRealReparacion: double.parse(_costo.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.inicial == null ? 'Nuevo daño' : 'Editar daño',
                style: theme.textTheme.titleLarge),
            const Gap(AppSpacing.lg),
            TextFormField(
              controller: _zona,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Zona del vehículo',
                hintText: 'Ej. Defensa frontal',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica la zona.' : null,
            ),
            const Gap(AppSpacing.md),
            DropdownButtonFormField<DamageType>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de daño'),
              items: [
                for (final t in DamageType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            const Gap(AppSpacing.md),
            DropdownButtonFormField<DamageSeverity>(
              initialValue: _severidad,
              decoration: const InputDecoration(labelText: 'Severidad'),
              items: [
                for (final s in DamageSeverity.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() => _severidad = v ?? _severidad),
            ),
            const Gap(AppSpacing.md),
            TextFormField(
              controller: _costo,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Costo real de reparación',
                prefixText: '\$ ',
              ),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Ingresa un costo válido.';
                return null;
              },
            ),
            const Gap(AppSpacing.xl),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: AppColors.blueprint,
                  elevation: 0,
                ),
                child: const Text('Guardar daño'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapLink extends StatelessWidget {
  const _MiniMapLink({required this.latitud, required this.longitud});

  final double latitud;
  final double longitud;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (latitud == 0 && longitud == 0) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.blueprint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.blueprint.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: () => launchUrl(
          Uri.parse('https://www.google.com/maps?q=$latitud,$longitud'),
          mode: LaunchMode.externalApplication,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Row(
          children: [
            Icon(Icons.map_outlined, size: 18, color: AppColors.blueprint),
            const Gap(AppSpacing.sm),
            Expanded(
              child: Text(
                '${latitud.toStringAsFixed(5)}, ${longitud.toStringAsFixed(5)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.blueprint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.open_in_new, size: 14, color: AppColors.blueprint),
          ],
        ),
      ),
    );
  }
}