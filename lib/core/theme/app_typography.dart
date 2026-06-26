import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    final base = GoogleFonts.interTextTheme();
    return GoogleFonts.archivoTextTheme(base).copyWith(
      displayLarge: GoogleFonts.archivo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0A1F3C),
      ),
      displayMedium: GoogleFonts.archivo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0A1F3C),
      ),
      headlineLarge: GoogleFonts.archivo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0A1F3C),
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0A1F3C),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0A1F3C),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF0A1F3C),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF6B7280),
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF9CA3AF),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0A1F3C),
      ),
    );
  }
}
