import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/document_type.dart';

class CaptureOverlay extends StatelessWidget {
  const CaptureOverlay({
    super.key,
    required this.type,
    this.hasImage = false,
  });

  final DocumentType type;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          if (!hasImage) ...[
            Container(color: Colors.black.withValues(alpha: 0.3)),
            Center(
              child: Container(
                width: _frameWidth,
                height: _frameHeight,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.amber,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.08,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    type.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.hint,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double get _aspectRatio {
    return switch (type) {
      DocumentType.ineFront || DocumentType.ineBack => 85.6 / 54.0,
      DocumentType.policy => 215.9 / 279.4,
    };
  }

  double get _frameWidth => 280;
  double get _frameHeight => 280 / _aspectRatio;
}
