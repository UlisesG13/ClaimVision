import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/biometric/presentation/providers/biometric_providers.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../auth/presentation/state/onboarding_controller.dart';
import '../state/mis_siniestros_controller.dart';
import '../state/notificaciones_controller.dart';
import '../state/report_controller.dart';
import '../widgets/siniestro_card.dart';

/// Inicio del Cliente (Figma node 70:344).
class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  bool _primerInicioChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(misSiniestrosControllerProvider);
      _checkPrimerInicio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(currentSessionProvider);
    final siniestrosAsync = ref.watch(misSiniestrosControllerProvider);
    final store = ref.read(misSiniestrosControllerProvider.notifier);
    final poliza = ref.watch(
      onboardingControllerProvider.select((s) => s.numeroPoliza),
    );

    final nombre = _nombreDesdeEmail(session?.email);

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      bottomNavigationBar: ClaimVisionBottomNav(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              context.go(RoutePaths.historial);
            case 2:
              context.go(RoutePaths.perfil);
          }
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(misSiniestrosControllerProvider);
            await ref.read(misSiniestrosControllerProvider.future);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(
                nombre: nombre,
                poliza: poliza,
                noLeidas: ref.watch(notificacionesNoLeidasProvider),
                onLogout: () => _confirmLogout(context, ref),
                onBell: () => context.push(RoutePaths.notificaciones),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportCard(
                      onTap: () {
                        ref.read(reportControllerProvider.notifier).reset();
                        context.push(RoutePaths.reportar);
                      },
                    ),
                    const Gap(AppSpacing.lg),
                    _StatsRow(
                      activos: store.activos,
                      total: store.total,
                    ),
                    const Gap(AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Actividad Reciente',
                            style: theme.textTheme.titleLarge),
                        if (siniestrosAsync.hasValue && (siniestrosAsync.value?.isNotEmpty == true))
                          GestureDetector(
                            onTap: () => context.go(RoutePaths.historial),
                            child: Text('Ver todos',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: context.textPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                      ],
                    ),
                    const Gap(AppSpacing.md),
                    siniestrosAsync.when(
                      data: (siniestros) {
                        if (siniestros.isEmpty) return const _EmptyActivity();
                        return Column(
                          children: siniestros.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: SiniestroCard(
                              siniestro: s,
                              onTap: () => context.push(
                                  RoutePaths.detalleSiniestroDe(s.id)),
                            ),
                          )).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, _) => const _EmptyActivity(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _nombreDesdeEmail(String? email) {
    if (email == null || email.isEmpty) return 'Cliente';
    final local = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final salir = await AppDialog.confirm(
      context,
      title: 'Cerrar sesión',
      message:
          '¿Seguro que deseas salir de tu cuenta? Deberás iniciar sesión nuevamente.',
      confirmLabel: 'Cerrar sesión',
      danger: true,
    );
    if (salir) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _checkPrimerInicio() async {
    if (_primerInicioChecked) return;
    _primerInicioChecked = true;

    final session = ref.read(currentSessionProvider);
    final userId = session?.usuarioId;
    if (userId == null) return;

    final storage = ref.read(secureStorageProvider);
    final yaVisto = await storage.read(StorageKeys.primerInicioPara(userId));
    if (yaVisto == 'true') return;

    if (!mounted) return;
    final nuevaPassword = await _mostrarDialogoCambioPassword();
    if (!mounted) return;
    if (nuevaPassword != null) {
      await AppDialog.info(
        context,
        title: 'Contraseña actualizada',
        message: 'Tu contraseña ha sido cambiada correctamente.',
        icon: Icons.check_circle,
        accent: AppColors.success,
      );
    }

    if (!mounted) return;
    final biometricService = ref.read(biometricServiceProvider);
    final disponible = await biometricService.canCheckBiometrics();
    if (disponible && mounted) {
      await _mostrarDialogoBiometrico(password: nuevaPassword);
    }

    if (!mounted) return;
    await storage.write(StorageKeys.primerInicioPara(userId), 'true');
  }

  Future<String?> _mostrarDialogoCambioPassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    String? nuevaPassword;
    final cambioRealizado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Actualiza tu contraseña',
              style: theme.textTheme.titleLarge),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Por seguridad, te recomendamos cambiar tu contraseña por una que recuerdes fácilmente.',
                  style: theme.textTheme.bodyMedium,
                ),
                const Gap(AppSpacing.lg),
                AppTextField(
                  controller: currentCtrl,
                  hintText: 'Contraseña actual',
                  prefixIcon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingresa tu contraseña actual' : null,
                ),
                const Gap(AppSpacing.md),
                AppTextField(
                  controller: newCtrl,
                  hintText: 'Nueva contraseña',
                  prefixIcon: Icons.lock,
                  obscure: true,
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Omitir'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                AppDialog.showLoading(ctx, title: 'Actualizando contraseña…');
                try {
                  await ref.read(changePasswordProvider)(
                    oldPassword: currentCtrl.text,
                    newPassword: newCtrl.text,
                  );
                  if (ctx.mounted) {
                    AppDialog.hideLoading(ctx);
                    nuevaPassword = newCtrl.text;
                    Navigator.pop(ctx, true);
                  }
                } on Failure catch (e) {
                  if (ctx.mounted) {
                    AppDialog.hideLoading(ctx);
                    AppSnackbar.error(ctx, e.message);
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    currentCtrl.dispose();
    newCtrl.dispose();
    if (cambioRealizado == true && nuevaPassword != null) return nuevaPassword;
    return null;
  }

  Future<void> _mostrarDialogoBiometrico({String? password}) async {
    final acepto = await AppDialog.permission(
      context,
      icon: Icons.fingerprint,
      title: '¿Usar huella digital?',
      message:
          'Puedes usar tu huella digital o Face ID para iniciar sesión más rápido sin escribir tu contraseña.',
      allowLabel: 'Activar',
      denyLabel: 'Ahora no',
    );

    if (!acepto || !mounted) return;

    String? pass = password;
    if (pass == null) {
      final passCtrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final t = Theme.of(ctx);
          return AlertDialog(
            title: Text('Confirma tu contraseña', style: t.textTheme.titleLarge),
            content: AppTextField(
              controller: passCtrl,
              hintText: 'Contraseña actual',
              prefixIcon: Icons.lock_outline,
              obscure: true,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
      if (ok == true && passCtrl.text.isNotEmpty) {
        pass = passCtrl.text;
      }
      passCtrl.dispose();
    }

    if (pass == null || pass.isEmpty) return;

    final biometricService = ref.read(biometricServiceProvider);
    final autenticado = await biometricService.authenticate(
      reason: 'Registra tu huella para acceder más rápido',
    );
    if (!autenticado) return;

    if (!mounted) return;
    final biometricRepo = ref.read(biometricRepositoryProvider);
    final session = ref.read(currentSessionProvider);
    if (session?.email != null) {
      await biometricRepo.enable(
        userId: session!.usuarioId,
        email: session.email,
        password: pass,
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.nombre,
    required this.poliza,
    required this.noLeidas,
    required this.onLogout,
    required this.onBell,
  });

  final String nombre;
  final String poliza;
  final int noLeidas;
  final VoidCallback onLogout;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iniciales = nombre.trim().isEmpty
        ? 'CL'
        : nombre
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase();
    final subtitulo =
        poliza.trim().isEmpty ? 'Bienvenido' : 'Póliza $poliza';

    return Container(
      color: context.cardColor,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLogout,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.blueprint,
              child: Text(
                iniciales,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hola, $nombre', style: theme.textTheme.titleLarge),
                Text(subtitulo, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onBell,
                icon: const Icon(Icons.notifications_none,
                    color: AppColors.blueprint),
              ),
              if (noLeidas > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(
                        color: AppColors.alert, shape: BoxShape.circle),
                    child: Text(
                      noLeidas > 9 ? '9+' : '$noLeidas',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.blueprint,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueprint.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.add, color: AppColors.blueprint, size: 26),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reportar Incidente',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      )),
                  Text('Inicia un nuevo siniestro',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward,
                color: AppColors.white.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.activos, required this.total});
  final int activos;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(value: activos, label: 'Activos')),
        const Gap(AppSpacing.md),
        Expanded(child: _StatBox(value: total, label: 'Total')),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value',
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 32)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined,
              size: 40, color: context.textHintColor),
          const Gap(AppSpacing.md),
          Text('Aún no has reportado siniestros',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.xs),
          Text(
            'Cuando reportes un incidente aparecerá aquí con su estado.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
