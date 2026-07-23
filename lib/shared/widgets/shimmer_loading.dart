import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 100, this.borderRadius});

  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.borderColor;
    final highlightColor = context.surfaceColor;
    return Shimmer.fromColors(
      baseColor: baseColor.withValues(alpha: 0.3),
      highlightColor: highlightColor.withValues(alpha: 0.6),
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.radiusLg),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 4, this.height = 100});

  final int count;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: count,
      itemBuilder: (_, _) => ShimmerCard(height: height),
    );
  }
}
