import 'package:claimvision/shared/domain/entities/siniestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/ajustador_bottom_nav.dart';
import '../state/casos_asignados_controller.dart';
import '../widgets/caso_card.dart';

/// Mis Casos Asignados — bandeja del ajustador (Figma node 72:980).
///
/// Lista los siniestros asignados (`GET /siniestros/asignados`) con búsqueda
/// local por folio/placas/vehículo. Maneja cargando / éxito / vacío / error.
class CasosAsignadosPage extends ConsumerStatefulWidget {
  const CasosAsignadosPage({super.key});

  @override
  ConsumerState<CasosAsignadosPage> createState() => _CasosAsignadosPageState();
}

class _CasosAsignadosPageState extends ConsumerState<CasosAsignadosPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(casosAsignadosControllerProvider);
    });
  }

  List<Siniestro> _filtrar(List<Siniestro> casos) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return casos;
    return casos.where((s) {
      return s.folioCorto.toLowerCase().contains(q) ||
          s.vehiculoPlacas.toLowerCase().contains(q) ||
          s.vehiculoResumen.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentSessionProvider);
    final casosAsync = ref.watch(casosAsignadosControllerProvider);
    final nombre = _nombre(session?.email);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AjustadorBottomNav(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 1:
              context.go(RoutePaths.notificacionesAjustador);
            case 2:
              context.go(RoutePaths.perfil);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(nombre: nombre),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
              child: _SearchBar(
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: casosAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  mensaje: e is Failure
                      ? e.message
                      : 'No se pudieron cargar tus casos.',
                  onReintentar: () => ref
                      .read(casosAsignadosControllerProvider.notifier)
                      .refrescar(),
                ),
                data: (casos) {
                  final filtrados = _filtrar(casos);
                  if (casos.isEmpty) return const _EmptyState();
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(casosAsignadosControllerProvider.notifier).refrescar(),
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        Text(
                          '${filtrados.length} ${filtrados.length == 1 ? 'caso' : 'casos'} · Validación técnica',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Gap(AppSpacing.md),
                        for (final s in filtrados)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: CasoCard(
                              siniestro: s,
                              onValidar: () => context
                                  .push(RoutePaths.casoDetalleDe(s.id)),
                            ),
                          ),
                        if (filtrados.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xxl),
                            child: Center(
                              child: Text('Sin resultados para "$_query".',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nombre(String? email) {
    if (email == null || email.isEmpty) return 'Ajustador';
    final local = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.nombre});
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iniciales = nombre.trim().isEmpty
        ? 'AJ'
        : nombre.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.blueprint,
            child: Text(iniciales,
                style:
                    theme.textTheme.labelLarge?.copyWith(color: AppColors.white)),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $nombre', style: theme.textTheme.titleLarge),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppColors.success),
                    const Gap(AppSpacing.xs),
                    Text('Activo para servicio',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por folio, placa o vehículo',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFC4C6CE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFC4C6CE)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_turned_in_outlined,
                size: 48, color: AppColors.textHint),
            const Gap(AppSpacing.md),
            Text('Sin casos asignados', style: theme.textTheme.titleMedium),
            const Gap(AppSpacing.xs),
            Text('Cuando tu aseguradora te asigne un siniestro, aparecerá aquí.',
                textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.mensaje, required this.onReintentar});
  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.textHint),
            const Gap(AppSpacing.md),
            Text(mensaje,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const Gap(AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
