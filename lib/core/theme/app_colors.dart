import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color blueprint = Color(0xFF0A1F3C);
  static const Color blueprintLight = Color(0xFF14305C);
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

  // ── Dark mode ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextHint = Color(0xFF808080);

  static const ColorSeverity severity = ColorSeverity();

  /// Retorna [color] en modo oscuro si [isDark] es `true`, de lo contrario [color].
  static Color adapt(Color light, Color dark, bool isDark) =>
      isDark ? dark : light;
}

/// Extension que expone colores adaptados al [Brightness] desde cualquier [BuildContext].
extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor =>
      AppColors.adapt(AppColors.white, AppColors.darkSurface, isDarkMode);

  Color get cardColor =>
      AppColors.adapt(AppColors.surfaceCard, AppColors.darkCard, isDarkMode);

  Color get scaffoldBgColor =>
      AppColors.adapt(AppColors.background, AppColors.darkBackground, isDarkMode);

  Color get textPrimaryColor =>
      AppColors.adapt(AppColors.textPrimary, AppColors.darkTextPrimary, isDarkMode);

  Color get textSecondaryColor =>
      AppColors.adapt(AppColors.textSecondary, AppColors.darkTextSecondary, isDarkMode);

  Color get textHintColor =>
      AppColors.adapt(AppColors.textHint, AppColors.darkTextHint, isDarkMode);

  Color get borderColor =>
      AppColors.adapt(AppColors.borderLight, AppColors.darkBorder, isDarkMode);
}

class ColorSeverity {
  const ColorSeverity();

  Color get low => AppColors.success;
  Color get medium => AppColors.amber;
  Color get high => AppColors.alert;
}
