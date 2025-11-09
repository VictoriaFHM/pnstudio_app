import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme withInter(TextTheme base) {
    final inter = GoogleFonts.interTextTheme(base);
    return inter.copyWith(
      headlineMedium: inter.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: inter.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: inter.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      labelLarge: inter.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
