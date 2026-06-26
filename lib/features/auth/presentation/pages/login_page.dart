import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/auth_controller.dart';

/// Pantalla de inicio de sesión (Figma node 101:64 — "Portal de Expertos").
///
/// Fondo "blueprint" con tarjeta blanca: correo, contraseña, recuperación,
/// botón "Entrar" y acceso biométrico. Conectada a `POST /api/auth/login` vía
/// [AuthController]; al autenticar, el router redirige al inicio según el rol.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _comingSoon(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Muestra un mensaje cuando el login falla (la UI nunca ve la excepción).
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is Failure
            ? error.message
            : 'No se pudo iniciar sesión. Inténtalo de nuevo.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.alert,
            ),
          );
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
                      onSubmit: _submit,
                      onForgot: () =>
                          _comingSoon('Recuperación de contraseña próximamente.'),
                      onBiometric: () =>
                          _comingSoon('Acceso biométrico próximamente.'),
                    ),
                    const Gap(AppSpacing.xl),
                    _Footer(
                      theme: theme,
                      onRegister: () => context.push(RoutePaths.register),
                    ),
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
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueprint.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.shield_outlined, color: AppColors.amber, size: 30),
        ),
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
            color: const Color(0xFFB4C7EC),
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
    required this.onSubmit,
    required this.onForgot,
    required this.onBiometric,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onForgot;
  final VoidCallback onBiometric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: const Color(0xFFC4C6CE)),
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
                    color: AppColors.blueprint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Gap(AppSpacing.md),
            PrimaryButton(
              label: 'Entrar',
              icon: Icons.arrow_forward,
              isLoading: isLoading,
              onPressed: onSubmit,
            ),
            const Gap(AppSpacing.xl),
            Row(
              children: [
                const Expanded(child: Divider(color: Color(0xFFE0E3E6))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    'o ingresar con',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(child: Divider(color: Color(0xFFE0E3E6))),
              ],
            ),
            const Gap(AppSpacing.lg),
            Center(
              child: InkWell(
                onTap: onBiometric,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 80, minHeight: 80),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: const Color(0xFFC4C6CE)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fingerprint,
                          size: 28, color: AppColors.blueprint),
                      const Gap(AppSpacing.sm),
                      Text(
                        'Biometría',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.theme, required this.onRegister});
  final ThemeData theme;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final infoStyle = theme.textTheme.bodySmall?.copyWith(
      color: const Color(0xFFB4C7EC).withValues(alpha: 0.6),
      fontWeight: FontWeight.w500,
    );
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta? ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB4C7EC),
              ),
            ),
            GestureDetector(
              onTap: onRegister,
              child: Text(
                'Crear cuenta',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.amber,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.lg),
        Text('Acceso restringido a personal autorizado.',
            textAlign: TextAlign.center, style: infoStyle),
        Text('v2.4.1 (Build 809)',
            textAlign: TextAlign.center, style: infoStyle),
      ],
    );
  }
}
