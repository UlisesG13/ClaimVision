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
import '../../../../shared/widgets/feedback/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../state/auth_controller.dart';

/// Pantalla de registro de usuario (Figma node 101:5).
///
/// Formulario claro con nombre, correo y contraseña. Conectada a
/// `POST /api/auth/register`, que devuelve un token (auto-login): al registrar,
/// el [AuthController] queda con sesión y el router redirige al inicio.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).register(
          nombre: _nombreController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        final message = error is Failure
            ? error.message
            : 'No se pudo crear la cuenta. Inténtalo de nuevo.';
        AppSnackbar.error(context, message);
      }
      // Registro exitoso (nuevo usuario) → continuar al onboarding de póliza.
      final authed = next.asData?.value != null;
      final wasAuthed = previous?.asData?.value != null;
      if (authed && !wasAuthed) {
        context.go(RoutePaths.onboarding);
      }
    });

    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(theme: theme),
                  const Gap(AppSpacing.xl),
                  _RegisterCard(
                    formKey: _formKey,
                    nombreController: _nombreController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isLoading: isLoading,
                    onSubmit: _submit,
                  ),
                  const Gap(AppSpacing.xl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _goToLogin,
                        child: Text(
                          'Inicia Sesión',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.blueprint,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.blueprint, size: 32),
            const Gap(AppSpacing.sm),
            Text(
              'ClaimVision',
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
            ),
          ],
        ),
        const Gap(AppSpacing.lg),
        Text(
          'Registro de Usuario',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 26),
        ),
        const Gap(AppSpacing.sm),
        Text(
          'Configure su acceso seguro a la plataforma pericial.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.formKey,
    required this.nombreController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: const Color(0xFFC4C6CE)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueprint.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: nombreController,
              label: 'Nombre Completo',
              hintText: 'Ej. Roberto Sánchez',
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: Validators.fullName,
            ),
            const Gap(AppSpacing.md),
            AppTextField(
              controller: emailController,
              label: 'Correo Electrónico',
              hintText: 'usuario@correo.com',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const Gap(AppSpacing.md),
            AppTextField(
              controller: passwordController,
              label: 'Crear Contraseña',
              hintText: 'Mínimo 8 caracteres',
              prefixIcon: Icons.lock_outline,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: Validators.newPassword,
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const Gap(AppSpacing.xl),
            PrimaryButton(
              label: 'Crear Cuenta',
              icon: Icons.person_add_alt_1,
              isLoading: isLoading,
              foregroundColor: const Color(0xFF6D4400),
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
