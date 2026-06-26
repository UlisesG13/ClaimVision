import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color blueprint = Color(0xFF0A1F3C);
  static const Color amber = Color(0xFFFEAD3B);
  static const Color alert = Color(0xFFFF5A4D);
  static const Color success = Color(0xFF2EC27E);
  static const Color background = Color(0xFFF7FAFD);
  static const Color white = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF0A1F3C);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  static const ColorSeverity severity = ColorSeverity();
}

class ColorSeverity {
  const ColorSeverity();

  Color get low => AppColors.success;
  Color get medium => AppColors.amber;
  Color get high => AppColors.alert;
}
