import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/report_controller.dart';
import '../widgets/report_step_header.dart';

/// Reportar — Paso 2: Ubicación y Fecha (Figma node 70:490).
///
/// Captura la ubicación del siniestro por GPS. Al continuar se crea el
/// siniestro preliminar en el backend (`POST /siniestros/inicializar`), que
/// requiere vehículo + coordenadas. La fecha/hora la fija el servidor; aquí se
/// muestra de forma informativa.
class ReportLocationPage extends ConsumerStatefulWidget {
  const ReportLocationPage({super.key});

  @override
  ConsumerState<ReportLocationPage> createState() => _ReportLocationPageState();
}

class _ReportLocationPageState extends ConsumerState<ReportLocationPage> {
  bool _locating = false;
  final DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Intenta obtener la ubicación automáticamente al entrar (si no hay una).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(reportControllerProvider).ubicacionLista) {
        _obtenerUbicacion();
      }
    });
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _locating = true);
    try {
      final coord = await ref.read(locationServiceProvider).ubicacionActual();
      ref
          .read(reportControllerProvider.notifier)
          .setUbicacion(latitud: coord.latitud, longitud: coord.longitud);
    } on AppException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('No se pudo obtener tu ubicación. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    AppSnackbar.error(context, msg);
  }

  Future<void> _continuar() async {
    final ok = await ref.read(reportControllerProvider.notifier).crearSiniestro();
    if (ok && mounted) context.push(RoutePaths.reportarNarracion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reportControllerProvider);

    ref.listen(reportControllerProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg != null && msg.isNotEmpty) _snack(msg);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportStepHeader(
              subtitulo: 'Ubicación',
              pasoActual: 2,
              totalPasos: 4,
              onBack: () => context.canPop() ? context.pop() : null,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  _MapCard(
                    locating: _locating,
                    lista: state.ubicacionLista,
                    onTap: _locating ? null : _obtenerUbicacion,
                  ),
                  const Gap(AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _ReadField(
                          label: 'Latitud',
                          value: state.latitud?.toStringAsFixed(6) ?? '—',
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: _ReadField(
                          label: 'Longitud',
                          value: state.longitud?.toStringAsFixed(6) ?? '—',
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  _ReadField(
                    label: 'Ubicación aproximada',
                    icon: Icons.place_outlined,
                    value: state.ubicacionLista
                        ? '${state.latitud!.toStringAsFixed(4)}, ${state.longitud!.toStringAsFixed(4)}'
                        : 'Sin capturar',
                  ),
                  const Gap(AppSpacing.md),
                  _ReadField(
                    label: 'Fecha y hora del siniestro',
                    icon: Icons.calendar_today_outlined,
                    value: DateFormatEs.fechaHora(_fecha),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    'La hora oficial del siniestro la registra el sistema al enviar el reporte.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PrimaryButton(
                label: 'Continuar',
                icon: Icons.arrow_forward,
                isLoading: state.submitting,
                onPressed: state.ubicacionLista && !state.submitting ? _continuar : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.locating, required this.lista, this.onTap});
  final bool locating;
  final bool lista;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.blueprint.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (locating)
              const CircularProgressIndicator(color: AppColors.blueprint)
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: lista ? AppColors.success : AppColors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: AppColors.white),
              ),
            const Gap(AppSpacing.md),
            Text(
              locating
                  ? 'Obteniendo tu ubicación…'
                  : lista
                      ? 'Ubicación capturada · toca para actualizar'
                      : 'Toca para usar mi ubicación actual',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadField extends StatelessWidget {
  const _ReadField({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            )),
        const Gap(AppSpacing.sm),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: const Color(0xFFC4C6CE)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const Gap(AppSpacing.sm),
              ],
              Expanded(
                child: Text(value,
                    style: theme.textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
