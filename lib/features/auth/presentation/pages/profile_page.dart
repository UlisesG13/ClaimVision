import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/biometric/presentation/providers/biometric_providers.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/ajustador_bottom_nav.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../state/auth_controller.dart';
import '../state/onboarding_controller.dart';

/// Perfil de Usuario (Figma node 70:868).
///
/// Muestra los datos reales del usuario autenticado (`/auth/me` vía sesión) y
/// lo capturado en el onboarding (póliza + consentimientos). El backend no
/// expone aún nombre completo ni datos de aseguradora del cliente, así que se
/// muestran solo los datos disponibles. "Cerrar sesión" hace logout real.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _biometricEnabled = false;
  bool _biometricDisponible = false;

  @override
  void initState() {
    super.initState();
    _cargarEstadoBiometrico();
  }

  Future<void> _cargarEstadoBiometrico() async {
    final biometricRepo = ref.read(biometricRepositoryProvider);
    final enabled = await biometricRepo.isEnabled();
    final service = ref.read(biometricServiceProvider);
    final disponible = await service.canCheckBiometrics();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricDisponible = disponible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(currentSessionProvider);
    final onboarding = ref.watch(onboardingControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    final email = session?.email ?? '';
    final nombre = _nombreDesdeEmail(email);
    final rol = session?.rol.label ?? 'Cliente';
    final userId = session?.usuarioId;
    final tienePoliza = onboarding.numeroPoliza.trim().isNotEmpty;

    final esCliente = session?.rol.isCliente ?? true;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        title: Text('Mi Perfil',
            style: theme.textTheme.titleLarge?.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.bold,
            )),
      ),
      bottomNavigationBar: esCliente
          ? ClaimVisionBottomNav(
              currentIndex: 2,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(RoutePaths.inicio);
                  case 1:
                    context.go(RoutePaths.historial);
                }
              },
            )
          : AjustadorBottomNav(
              currentIndex: 2,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(RoutePaths.casos);
                  case 1:
                    context.go(RoutePaths.notificacionesAjustador);
                }
              },
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Header(nombre: nombre, email: email, rol: rol),
          const Gap(AppSpacing.lg),
          if (esCliente) ...[
            if (tienePoliza)
              _PolicyCard(
                numeroPoliza: onboarding.numeroPoliza,
                vigencia: onboarding.vigenciaPoliza,
                curpRfc: onboarding.curpRfc,
              )
            else
              _LinkPolicyCard(onTap: () => context.push(RoutePaths.onboarding)),
            const Gap(AppSpacing.lg),
            _ConsentCard(
              avisoPrivacidad: onboarding.avisoPrivacidad,
              biometria: onboarding.biometria,
              transferenciaTalleres: onboarding.transferenciaTalleres,
              sinDatos: !onboarding.hasDetected && !tienePoliza,
            ),
            const Gap(AppSpacing.lg),
            _MenuCard(
              onVehiculos: () => context.push(RoutePaths.vehiculos),
              onConfiguracion: () => _proximamente(context, 'Configuración'),
            ),
            const Gap(AppSpacing.lg),
          ],
          if (_biometricDisponible)
            _BiometricCard(
              enabled: _biometricEnabled,
              onChanged: (v) {
                if (v) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _showPasswordDialog(userId);
                  });
                } else {
                  _desactivarBiometria();
                }
              },
            ),
          const Gap(AppSpacing.lg),
          _ThemeCard(
            themeMode: themeMode,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode),
          ),
          const Gap(AppSpacing.lg),
          _LogoutButton(onTap: () => _confirmarLogout(context, ref)),
          const Gap(AppSpacing.md),
          Center(
            child: Text('ClaimVision · v1.0',
                style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  String _nombreDesdeEmail(String email) {
    if (email.isEmpty) return 'Cliente';
    final local = email.split('@').first.replaceAll(RegExp(r'[._]'), ' ');
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  void _proximamente(BuildContext context, String que) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$que — próximamente.')));
  }

  Future<void> _showPasswordDialog(String? userId) async {
    if (userId == null) return;

    final email = ref.read(currentSessionProvider)?.email;
    final biometricService = ref.read(biometricServiceProvider);
    final biometricRepo = ref.read(biometricRepositoryProvider);
    String captured = '';

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Confirma tu contraseña', style: theme.textTheme.titleLarge),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Contraseña actual',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            textInputAction: TextInputAction.done,
            onChanged: (v) => captured = v,
            onSubmitted: (_) => Future.microtask(() => Navigator.pop(ctx, true)),
          ),
          actions: [
            TextButton(
              onPressed: () => Future.microtask(() => Navigator.pop(ctx, false)),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
              onPressed: () => Future.microtask(() => Navigator.pop(ctx, true)),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (ok != true || captured.isEmpty || !mounted || email == null) return;

    final autenticado = await biometricService.authenticate(
      reason: 'Registra tu huella para acceder más rápido',
    );
    if (!autenticado || !mounted) return;

    await biometricRepo.enable(
      userId: userId,
      email: email,
      password: captured,
    );

    Future.microtask(() {
      if (mounted) setState(() => _biometricEnabled = true);
    });
  }

  Future<void> _desactivarBiometria() async {
    final biometricRepo = ref.read(biometricRepositoryProvider);
    await biometricRepo.disable();
    if (mounted) setState(() => _biometricEnabled = false);
  }

  Future<void> _confirmarLogout(BuildContext context, WidgetRef ref) async {
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
}

class _Header extends StatelessWidget {
  const _Header({required this.nombre, required this.email, required this.rol});
  final String nombre;
  final String email;
  final String rol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iniciales = nombre.trim().isEmpty
        ? 'CL'
        : nombre.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.blueprint,
            child: Text(iniciales,
                style: theme.textTheme.displayMedium
                    ?.copyWith(color: AppColors.white)),
          ),
          const Gap(AppSpacing.md),
          Text(nombre, style: theme.textTheme.headlineLarge),
          const Gap(AppSpacing.xs),
          Text(email,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: context.textSecondaryColor)),
          const Gap(AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: context.textPrimaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(rol,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                )),
          ),
        ],
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.numeroPoliza,
    required this.vigencia,
    required this.curpRfc,
  });
  final String numeroPoliza;
  final String vigencia;
  final String curpRfc;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      titulo: 'Mi Póliza',
      children: [
        _InfoRow(label: 'Número de Póliza', value: numeroPoliza),
        _InfoRow(label: 'Vigencia', value: vigencia.isEmpty ? '—' : vigencia),
        _InfoRow(label: 'CURP / RFC', value: _mask(curpRfc)),
      ],
    );
  }

  String _mask(String v) {
    if (v.trim().isEmpty) return '—';
    final t = v.trim();
    if (t.length <= 6) return '$t (cifrado)';
    return '${t.substring(0, 6)}••• (cifrado)';
  }
}

class _LinkPolicyCard extends StatelessWidget {
  const _LinkPolicyCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      titulo: 'Mi Póliza',
      children: [
        Text('Aún no has vinculado tu póliza.',
            style: theme.textTheme.bodyMedium),
        const Gap(AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add),
            label: const Text('Vincular póliza'),
          ),
        ),
      ],
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.avisoPrivacidad,
    required this.biometria,
    required this.transferenciaTalleres,
    required this.sinDatos,
  });
  final bool avisoPrivacidad;
  final bool biometria;
  final bool transferenciaTalleres;
  final bool sinDatos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      titulo: 'Consentimientos (ARCO)',
      children: sinDatos
          ? [
              Text('Se registran al vincular tu póliza.',
                  style: theme.textTheme.bodySmall),
            ]
          : [
              _ConsentRow(label: 'Aviso de privacidad', value: avisoPrivacidad),
              _ConsentRow(label: 'Datos biométricos', value: biometria),
              _ConsentRow(
                  label: 'Transferencia a talleres',
                  value: transferenciaTalleres),
            ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.onVehiculos, required this.onConfiguracion});
  final VoidCallback onVehiculos;
  final VoidCallback onConfiguracion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.directions_car_outlined,
                color: AppColors.blueprint),
            title: const Text('Vehículos registrados'),
            trailing: Icon(Icons.chevron_right,
                color: context.textHintColor),
            onTap: onVehiculos,
          ),
          Divider(height: 1, color: context.borderColor),
          ListTile(
            leading: const Icon(Icons.settings_outlined,
                color: AppColors.blueprint),
            title: const Text('Configuración'),
            trailing: Icon(Icons.chevron_right,
                color: context.textHintColor),
            onTap: onConfiguracion,
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Modo oscuro'),
            subtitle: const Text('Cambiar entre tema claro y oscuro'),
            secondary: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: AppColors.blueprint,
            ),
            value: themeMode == ThemeMode.dark,
            onChanged: (dark) {
              onChanged(dark ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }
}

class _BiometricCard extends StatelessWidget {
  const _BiometricCard({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        title: const Text('Usar huella digital'),
        subtitle: const Text('Accede sin escribir contraseña'),
        secondary: Icon(
          enabled ? Icons.fingerprint : Icons.fingerprint_outlined,
          color: enabled ? AppColors.amber : context.textHintColor,
        ),
        value: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.alert,
          side: BorderSide(color: AppColors.alert.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

// ── Helpers de UI ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.titulo, required this.children});
  final String titulo;
  final List<Widget> children;

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
          Text(titulo, style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
          const Gap(AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: context.textSecondaryColor)),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.label, required this.value});
  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Icon(
            value ? Icons.check_circle : Icons.cancel_outlined,
            size: 20,
            color: value ? AppColors.success : context.textHintColor,
          ),
        ],
      ),
    );
  }
}
