import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/vehiculo_cliente.dart';
import '../state/providers.dart';
import '../state/report_controller.dart';
import '../widgets/report_step_header.dart';

class ReportVehiclePage extends ConsumerStatefulWidget {
  const ReportVehiclePage({super.key});

  @override
  ConsumerState<ReportVehiclePage> createState() => _ReportVehiclePageState();
}

class _ReportVehiclePageState extends ConsumerState<ReportVehiclePage> {
  VehiculoCliente? _seleccionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(vehiculosClienteProvider);
    });
  }

  void _continuar() {
    if (_seleccionado == null) return;
    final v = _seleccionado!;
    ref.read(reportControllerProvider.notifier).setVehiculo(
          vehiculoId: v.id,
          marca: v.marca,
          modelo: v.modelo,
          anio: v.anio,
          placas: v.placas,
          vin: v.vin,
          vehiculoSeleccionado: v,
        );
    context.push(RoutePaths.reportarUbicacion);
  }

  bool get _hayProgreso => _seleccionado != null;

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
    final vehiculosAsync = ref.watch(vehiculosClienteProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _intentarSalir();
      },
      child: Scaffold(
        backgroundColor: context.scaffoldBgColor,
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
                child: vehiculosAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.alert),
                          const Gap(AppSpacing.md),
                          Text('No se pudieron cargar tus vehículos.',
                              style: theme.textTheme.titleMedium),
                          const Gap(AppSpacing.xs),
                              Text('$err',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: context.textSecondaryColor)),
                          const Gap(AppSpacing.lg),
                          PrimaryButton(
                            label: 'Reintentar',
                            onPressed: () =>
                                ref.invalidate(vehiculosClienteProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (vehiculos) {
                    if (vehiculos.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_car_outlined,
                                  size: 48, color: context.textHintColor),
                              const Gap(AppSpacing.md),
                              Text('Sin vehículos registrados',
                                  style: theme.textTheme.titleMedium),
                              const Gap(AppSpacing.xs),
                              Text(
                                'No tienes vehículos asociados a tu póliza. '
                                'Contacta a tu aseguradora.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: context.textSecondaryColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        Text('Selecciona tu vehículo asegurado',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontSize: 14)),
                        const Gap(AppSpacing.lg),
                        ...vehiculos.map((v) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _VehiculoTile(
                                vehiculo: v,
                                seleccionado: _seleccionado?.id == v.id,
                                onTap: () =>
                                    setState(() => _seleccionado = v),
                              ),
                            )),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: PrimaryButton(
                  label: 'Continuar',
                  icon: Icons.arrow_forward,
                  onPressed: _seleccionado != null ? _continuar : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehiculoTile extends StatelessWidget {
  const _VehiculoTile({
    required this.vehiculo,
    required this.seleccionado,
    required this.onTap,
  });

  final VehiculoCliente vehiculo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vin = vehiculo.vin;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.blueprint.withValues(alpha: 0.06) : context.cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: seleccionado ? AppColors.blueprint : context.borderColor,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.blueprint.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                seleccionado ? Icons.check_circle : Icons.directions_car,
                color: seleccionado ? AppColors.blueprint : context.textHintColor,
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehiculo.marca} ${vehiculo.modelo} ${vehiculo.anio}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: seleccionado ? FontWeight.w600 : null,
                    ),
                  ),
                  const Gap(2),
                  Text('Placas: ${vehiculo.placas}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: context.textSecondaryColor)),
                  if (vin != null && vin.isNotEmpty)
                    Text('VIN: $vin',
                        style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
