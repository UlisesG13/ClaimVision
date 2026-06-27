import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/report_controller.dart';
import '../widgets/report_step_header.dart';

/// Reportar — Paso 1: Datos del Vehículo (Figma node 70:435).
///
/// Captura los datos del vehículo asegurado y los guarda en el borrador del
/// reporte ([reportControllerProvider]); el siniestro se crea en el backend
/// hasta el paso de Ubicación (#6), que es cuando se tienen vehículo + GPS.
class ReportVehiclePage extends ConsumerStatefulWidget {
  const ReportVehiclePage({super.key});

  @override
  ConsumerState<ReportVehiclePage> createState() => _ReportVehiclePageState();
}

class _ReportVehiclePageState extends ConsumerState<ReportVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _anio;
  late final TextEditingController _placas;
  late final TextEditingController _vin;

  @override
  void initState() {
    super.initState();
    // Reabrir el paso conserva lo ya capturado en el borrador.
    final s = ref.read(reportControllerProvider);
    _marca = TextEditingController(text: s.marca);
    _modelo = TextEditingController(text: s.modelo);
    _anio = TextEditingController(text: s.anio);
    _placas = TextEditingController(text: s.placas);
    _vin = TextEditingController(text: s.vin);
  }

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _anio.dispose();
    _placas.dispose();
    _vin.dispose();
    super.dispose();
  }

  void _continuar() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ref.read(reportControllerProvider.notifier).setVehiculo(
          marca: _marca.text,
          modelo: _modelo.text,
          anio: _anio.text,
          placas: _placas.text,
          vin: _vin.text,
        );
    context.push(RoutePaths.reportarUbicacion);
  }

  String? _anioValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa el año.';
    final anio = int.tryParse(value.trim());
    final actual = DateTime.now().year;
    if (anio == null) return 'Año inválido.';
    if (anio < 1950 || anio > actual + 1) return 'Año fuera de rango.';
    return null;
  }

  bool get _hayProgreso =>
      _marca.text.isNotEmpty ||
      _modelo.text.isNotEmpty ||
      _anio.text.isNotEmpty ||
      _placas.text.isNotEmpty ||
      _vin.text.isNotEmpty;

  /// Pide confirmación para descartar el reporte si hay datos capturados.
  Future<void> _intentarSalir() async {
    if (!_hayProgreso) {
      if (context.canPop()) context.pop();
      return;
    }
    final descartar = await AppDialog.confirm(
      context,
      title: '¿Descartar reporte?',
      message:
          'Perderás la información capturada del siniestro. Esta acción no se puede deshacer.',
      confirmLabel: 'Descartar',
      danger: true,
    );
    if (descartar && mounted) {
      ref.read(reportControllerProvider.notifier).reset();
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _intentarSalir();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReportStepHeader(
                subtitulo: 'Vehículo',
                pasoActual: 1,
                totalPasos: 4,
                onBack: _intentarSalir,
              ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    Text('Datos del vehículo asegurado',
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                    const Gap(AppSpacing.lg),
                    AppTextField(
                      controller: _marca,
                      label: 'Marca',
                      hintText: 'Ej. Toyota',
                      prefixIcon: Icons.directions_car_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.requiredField(v, campo: 'La marca'),
                    ),
                    const Gap(AppSpacing.md),
                    AppTextField(
                      controller: _modelo,
                      label: 'Modelo',
                      hintText: 'Ej. RAV4',
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.requiredField(v, campo: 'El modelo'),
                    ),
                    const Gap(AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _anio,
                            label: 'Año',
                            hintText: '2023',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: _anioValidator,
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            controller: _placas,
                            label: 'Placas',
                            hintText: 'GTX-441',
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                Validators.requiredField(v, campo: 'Las placas'),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.md),
                    AppTextField(
                      controller: _vin,
                      label: 'VIN (opcional)',
                      hintText: '1HGCM82633A004352',
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                onPressed: _continuar,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
