import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'shimmer_loading.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.shimmerCount = 4,
    this.shimmerHeight = 100,
    this.onRetry,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final int shimmerCount;
  final double shimmerHeight;
  final VoidCallback? onRetry;
  final Widget Function(Object error, StackTrace? stack)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => ShimmerList(count: shimmerCount, height: shimmerHeight),
      error: (err, stack) {
        if (error != null) return error!(err, stack);
        final theme = Theme.of(context);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: AppColors.alert.withValues(alpha: 0.6)),
                const Gap(AppSpacing.md),
                Text(
                  'Algo salió mal',
                  style: theme.textTheme.titleMedium,
                ),
                const Gap(AppSpacing.xs),
                Text(
                  _mensajeAmigable(err),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                if (onRetry != null) ...[
                  const Gap(AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      data: data,
    );
  }

  String _mensajeAmigable(Object err) {
    final m = err.toString();
    if (m.contains('SocketException') || m.contains('No address')) {
      return 'No hay conexión a internet. Verifica tu conexión e intenta de nuevo.';
    }
    if (m.contains('TimeoutException')) {
      return 'La solicitud tardó demasiado. Intenta de nuevo.';
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
