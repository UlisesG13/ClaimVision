import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/ajustador_bottom_nav.dart';
import '../../../../shared/widgets/biometric_toggle.dart';
import '../../../../shared/widgets/brand_app_bar.dart';
import '../../../../shared/widgets/claim_vision_bottom_nav.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../shared/widgets/theme_mode_toggle.dart';
import '../state/auth_controller.dart';
import '../state/onboarding_controller.dart';
import '../state/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(currentSessionProvider);

    final email = session?.email ?? '';
    final nombre = _nombreDesdeEmail(email);
    final rol = session?.rol.label ?? 'Cliente';

    final esCliente = session?.rol.isCliente ?? true;

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: BrandAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimaryColor),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text('Configuración',
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
      body: SafeArea(top: false, child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Header(nombre: nombre, email: email, rol: rol),
          const Gap(AppSpacing.lg),

          // ─── Seguridad ──────────────────────────────────────────────
          _SectionCard(
            titulo: 'Seguridad',
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.blueprint),
                title: const Text('Cambiar contraseña'),
                trailing: Icon(Icons.chevron_right, color: context.textHintColor),
                onTap: _mostrarDialogoCambiarPassword,
              ),
              const BiometricToggle(),
            ],
          ),
          const Gap(AppSpacing.lg),

          // ─── Cuenta (solo cliente) ──────────────────────────────────
          // Documentos, vehículos y consentimientos ARCO son propios del
          // cliente que vincula su póliza; el ajustador no los tiene.
          if (esCliente) ...[
            _SectionCard(
              titulo: 'Cuenta',
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.blueprint),
                  title: const Text('Mis documentos'),
                  trailing: Icon(Icons.chevron_right, color: context.textHintColor),
                  onTap: () => context.push(RoutePaths.documentos),
                ),
                Divider(height: 1, color: context.borderColor),
                ListTile(
                  leading: const Icon(Icons.directions_car_outlined, color: AppColors.blueprint),
                  title: const Text('Vehículos registrados'),
                  trailing: Icon(Icons.chevron_right, color: context.textHintColor),
                  onTap: () => context.push(RoutePaths.vehiculos),
                ),
                Divider(height: 1, color: context.borderColor),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: AppColors.blueprint),
                  title: const Text('Consentimientos (ARCO)'),
                  trailing: Icon(Icons.chevron_right, color: context.textHintColor),
                  onTap: _mostrarConsentimientos,
                ),
              ],
            ),
            const Gap(AppSpacing.lg),
          ],

          // ─── Apariencia ─────────────────────────────────────────────
          const ThemeModeToggle(),
          const Gap(AppSpacing.lg),

          // ─── Información ────────────────────────────────────────────
          _SectionCard(
            titulo: 'Información',
            children: [
              _InfoRow(label: 'Versión', value: '1.0.0'),
              _InfoRow(label: 'Entorno', value: 'Producción'),
              _InfoRow(
                label: 'Términos y condiciones',
                value: '',
                onTap: () => context.push(RoutePaths.terminos),
              ),
              _InfoRow(
                label: 'Aviso de privacidad',
                value: '',
                onTap: () => context.push(RoutePaths.avisoPrivacidad),
              ),
            ],
          ),
          const Gap(AppSpacing.lg),

          // ─── Peligro ────────────────────────────────────────────────
          _LogoutButton(onTap: () => _confirmarLogout(context, ref)),
          const Gap(AppSpacing.md),
          Center(
            child: Text('ClaimVision · v1.0',
                style: theme.textTheme.bodySmall),
          ),
        ],
      )),
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

  Future<void> _mostrarDialogoCambiarPassword() async {
    String current = '';
    String nuevo = '';
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Cambiar contraseña', style: theme.textTheme.titleLarge),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña actual',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onChanged: (v) => current = v,
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const Gap(AppSpacing.md),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onChanged: (v) => nuevo = v,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const Gap(AppSpacing.md),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v != nuevo ? 'No coinciden' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.blueprint),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    final changePassword = ref.read(changePasswordProvider);
    try {
      await changePassword(oldPassword: current, newPassword: nuevo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _mostrarConsentimientos() {
    final onboarding = ref.read(onboardingControllerProvider);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consentimientos (ARCO)', style: theme.textTheme.titleLarge),
              const Gap(AppSpacing.md),
              _ConsentRow(label: 'Aviso de privacidad', value: onboarding.avisoPrivacidad),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => sheetContext.push(RoutePaths.avisoPrivacidad),
                  child: Text(
                    'Ver documento completo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.blueprint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.sm),
              _ConsentRow(label: 'Datos biométricos', value: onboarding.biometria),
              _ConsentRow(label: 'Transferencia a talleres', value: onboarding.transferenciaTalleres),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmarLogout(BuildContext context, WidgetRef ref) async {
    final salir = await AppDialog.confirm(
      context,
      title: 'Cerrar sesión',
      message: '¿Seguro que deseas salir de tu cuenta? Deberás iniciar sesión nuevamente.',
      confirmLabel: 'Cerrar sesión',
      danger: true,
    );
    if (salir) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────
// Widgets reutilizados (extraídos de profile_page.dart)

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
                style: theme.textTheme.displayMedium?.copyWith(color: AppColors.white)),
          ),
          const Gap(AppSpacing.md),
          Text(nombre, style: theme.textTheme.headlineLarge),
          const Gap(AppSpacing.xs),
          Text(email,
              style: theme.textTheme.bodyMedium?.copyWith(color: context.textSecondaryColor)),
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
  const _InfoRow({required this.label, this.value = '', this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: context.textSecondaryColor))),
          const Gap(AppSpacing.md),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              child: Text(value.isEmpty ? 'Ver' : value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueprint,
                  )),
            )
          else
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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