import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/biometric/presentation/providers/biometric_providers.dart';
import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class BiometricToggle extends ConsumerStatefulWidget {
  const BiometricToggle({super.key});

  @override
  ConsumerState<BiometricToggle> createState() => _BiometricToggleState();
}

class _BiometricToggleState extends ConsumerState<BiometricToggle> {
  bool _enabled = false;
  bool _disponible = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final biometricRepo = ref.read(biometricRepositoryProvider);
    final enabled = await biometricRepo.isEnabled();
    final service = ref.read(biometricServiceProvider);
    final disponible = await service.canCheckBiometrics();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _disponible = disponible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_disponible) return const SizedBox.shrink();

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
          _enabled ? Icons.fingerprint : Icons.fingerprint_outlined,
          color: _enabled ? AppColors.amber : context.textHintColor,
        ),
        value: _enabled,
        onChanged: (v) {
          if (v) {
            _mostrarDialogo();
          } else {
            _desactivar();
          }
        },
      ),
    );
  }

  Future<void> _mostrarDialogo() async {
    final session = ref.read(currentSessionProvider);
    final usuarioId = session?.usuarioId;
    final email = session?.email;
    if (usuarioId == null || email == null) return;

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

    if (ok != true || captured.isEmpty || !mounted || email.isEmpty) return;

    final autenticado = await biometricService.authenticate(
      reason: 'Registra tu huella para acceder más rápido',
    );
    if (!autenticado || !mounted) return;

    await biometricRepo.enable(userId: usuarioId, email: email, password: captured);

    if (mounted) setState(() => _enabled = true);
  }

  Future<void> _desactivar() async {
    final biometricRepo = ref.read(biometricRepositoryProvider);
    await biometricRepo.disable();
    if (mounted) setState(() => _enabled = false);
  }
}
