import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/biometric/presentation/providers/biometric_providers.dart';
import '../../../../core/constants/app_info.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/services/screenshot_protection_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/feedback/app_dialog.dart';
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _biometricDisponible = false;
  bool _autoIntentado = false;
  bool _avisoAceptado = false;
  final _screenshotProtection = ScreenshotProtectionService();

  @override
  void initState() {
    super.initState();
    _screenshotProtection.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarEstadoAviso();
      await _revisarBiometria();
    });
  }

  @override
  void dispose() {
    _screenshotProtection.disable();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Pre-marca el checkbox si el último usuario de este dispositivo ya aceptó
  /// el aviso en un login anterior.
  Future<void> _cargarEstadoAviso() async {
    final storage = ref.read(secureStorageProvider);
    final ultimoId = await storage.read(StorageKeys.ultimoUsuarioId);
    if (ultimoId == null) return;
    final aceptado = await storage.read(StorageKeys.avisoAceptadoPara(ultimoId));
    if (aceptado == 'true' && mounted) {
      setState(() => _avisoAceptado = true);
    }
  }

  Future<void> _revisarBiometria() async {
    final service = ref.read(biometricServiceProvider);
    final disponible = await service.canCheckBiometrics();
    if (!disponible) return;

    if (!mounted) return;
    setState(() {
      _biometricDisponible = true;
    });

    if (_autoIntentado) return;
    _autoIntentado = true;

    // El aviso de privacidad es gate también para el acceso biométrico.
    if (!_avisoAceptado) return;

    final biometricRepo = ref.read(biometricRepositoryProvider);
    final enabled = await biometricRepo.isEnabled();
    if (!enabled) return;

    await _autenticarConBiometria();
  }

  Future<void> _submit() async {
    if (!_avisoAceptado) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  Future<void> _mostrarModalOlvide() async {
    if (!mounted) return;
    await AppDialog.info(
      context,
      title: '¿Olvidaste tu contraseña?',
      message:
          'Tu acceso fue creado por tu aseguradora. Por favor, contacta con '
          'ellos directamente para restablecer tu contraseña.',
    );
  }

  Future<void> _autenticarConBiometria() async {
    if (!_avisoAceptado) return;
    final service = ref.read(biometricServiceProvider);
    final biometricRepo = ref.read(biometricRepositoryProvider);

    try {
      final autenticado = await service.authenticate(
        reason: 'Acceso rápido a tu cuenta',
      );

      if (!autenticado) {
        if (mounted) AppSnackbar.error(context, 'Autenticación biométrica falló');
        return;
      }

      if (!mounted) return;
      final creds = await biometricRepo.getCredentials();

      if (creds == null) {
        if (mounted) {
          AppSnackbar.warning(
            context,
            'No hay datos biométricos. Actívalos desde Mi Perfil.',
          );
        }
        return;
      }

      if (!mounted) return;
      await ref.read(authControllerProvider.notifier).login(
            email: creds.email,
            password: creds.encryptedPassword,
          );
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'Ocurrió un error al usar la biometría.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(authControllerProvider, (previous, next) {
      final prevData = previous?.asData?.value;
      final nextData = next.asData?.value;
      // Resetear biometría al cerrar sesión (prev tenía session, next no)
      if (prevData != null && nextData == null) {
        _autoIntentado = false;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _revisarBiometria();
        });
      }
      // Login exitoso → persistir aceptación del aviso para este usuario.
      if (prevData == null && nextData != null) {
        final storage = ref.read(secureStorageProvider);
        storage.write(StorageKeys.ultimoUsuarioId, nextData.usuarioId);
        storage.write(
            StorageKeys.avisoAceptadoPara(nextData.usuarioId), 'true');
      }
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is Failure
            ? error.message
            : 'No se pudo iniciar sesión. Inténtalo de nuevo.';
        AppSnackbar.error(context, message);
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.blueprint,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.1,
            colors: [Color(0xFF14305C), AppColors.blueprint],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(theme: theme),
                    const Gap(AppSpacing.xxl),
                    _LoginCard(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      isLoading: isLoading,
                      avisoAceptado: _avisoAceptado,
                      onToggleAviso: (v) =>
                          setState(() => _avisoAceptado = v),
                      onSubmit: _submit,
                      onForgot: _mostrarModalOlvide,
                    ),
                    const Gap(AppSpacing.lg),
                    const _LegalLinks(),
                    if (_biometricDisponible) ...[
                      const Gap(AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(child: Divider(color: context.borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            child: Text(
                              'o ingresar con',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: context.borderColor)),
                        ],
                      ),
                      const Gap(AppSpacing.lg),
                      _BotonBiometrico(onPressed: _autenticarConBiometria),
                    ],
                    const Gap(AppSpacing.xl),
                    _Footer(theme: theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(size: 56, glow: true),
        const Gap(AppSpacing.sm),
        Text(
          'ClaimVision',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayLarge?.copyWith(
            color: AppColors.white,
            fontSize: 36,
          ),
        ),
        const Gap(AppSpacing.xs),
        Text(
          'Portal de Expertos',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Color(0xFFB4C7EC),
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.avisoAceptado,
    required this.onToggleAviso,
    required this.onSubmit,
    required this.onForgot,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool avisoAceptado;
  final ValueChanged<bool> onToggleAviso;
  final VoidCallback onSubmit;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueprint.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar Sesión',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const Gap(AppSpacing.xl),
            AppTextField(
              controller: emailController,
              hintText: 'Correo Electrónico',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const Gap(AppSpacing.md),
            AppTextField(
              controller: passwordController,
              hintText: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: Validators.password,
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const Gap(AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onForgot,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            _AvisoCheckbox(
              value: avisoAceptado,
              onChanged: onToggleAviso,
            ),
            const Gap(AppSpacing.md),
            PrimaryButton(
              label: 'Entrar',
              icon: Icons.arrow_forward,
              isLoading: isLoading,
              onPressed: avisoAceptado ? onSubmit : null,
            ),
            const Gap(AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _BotonBiometrico extends StatelessWidget {
  const _BotonBiometrico({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, color: AppColors.amber, size: 24),
            const Gap(AppSpacing.sm),
            Text(
              'Huella digital',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoCheckbox extends StatelessWidget {
  const _AvisoCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.blueprint,
                side: BorderSide(color: context.borderColor, width: 1.5),
              ),
            ),
            const Gap(AppSpacing.sm),
            Expanded(
              child: Text(
                'He leído y acepto el Aviso de Privacidad',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFFB4C7EC),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFFB4C7EC),
        );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GestureDetector(
          onTap: () => context.push(RoutePaths.avisoPrivacidad),
          child: Text('Aviso de Privacidad', style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('·',
              style: style?.copyWith(decoration: TextDecoration.none)),
        ),
        GestureDetector(
          onTap: () => context.push(RoutePaths.terminos),
          child: Text('Términos y Condiciones', style: style),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final infoStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFFB4C7EC).withValues(alpha: 0.6),
      fontWeight: FontWeight.w500,
    );
    return Column(
      children: [
        Text('Acceso restringido a personal autorizado.',
            textAlign: TextAlign.center, style: infoStyle),
        Text(AppInfo.displayVersion,
            textAlign: TextAlign.center, style: infoStyle),
      ],
    );
  }
}
