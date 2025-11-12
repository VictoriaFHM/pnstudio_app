import 'package:flutter/material.dart';

/// Design tokens - Sistema de tokens unificado para la aplicación
class DesignTokens {
  // ===== PALETA DE COLORES =====
  
  // Verde Oliva - Marca principal
  static const Color olive600 = Color(0xFF6E8C1A); // Verde principal (updated)
  static const Color olive700 = Color(0xFF5A7315); // Hover/Active (darker)
  static const Color olive200 = Color(0xFFCFE0A8); // Borde/Sutil

  // Arena - Fondos
  static const Color sand50 = Color(0xFFF3EDE4);   // Fondo página
  static const Color sand100 = Color(0xFFE8DFD3);  // Contenedores suaves

  // Tinta - Textos
  static const Color ink900 = Color(0xFF1F1F1F);   // Títulos
  static const Color ink700 = Color(0xFF2F2F2F);   // Texto principal
  static const Color ink500 = Color(0xFF5C5C5C);   // Texto secundario

  // Estados
  static const Color success50 = Color(0xFFEEF6E9); // Banner suave
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // ===== TIPOGRAFÍA =====
  
  static const double fontSizeH1 = 32.0;
  static const double fontSizeH2 = 24.0;
  static const double fontSizeH3 = 20.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeBodySmall = 15.0;
  static const double fontSizeCaption = 14.0;
  static const double fontSizeLabel = 12.0;

  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;
  static const FontWeight weightRegular = FontWeight.w400;

  static const double lineHeightTight = 1.2;
  static const double lineHeightBase = 1.5;
  static const double lineHeightRelaxed = 1.75;

  static const double letterSpacingBase = 0.2;

  // ===== ESPACIADO =====
  
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacing2xl = 24.0;
  static const double spacing3xl = 32.0;
  static const double spacing4xl = 40.0;

  // ===== RADIOS =====
  
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 999.0; // Para pill/stadium shape

  // ===== SOMBRAS =====
  
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacidad
      blurRadius: 12.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1F000000), // 12% opacidad
      blurRadius: 20.0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x2D000000), // 18% opacidad
      blurRadius: 28.0,
      offset: Offset(0, 12),
    ),
  ];

  // Shadow on hover
  static const List<BoxShadow> shadowHover = [
    BoxShadow(
      color: Color(0x26000000), // +10% más opaca
      blurRadius: 24.0,
      offset: Offset(0, 10),
    ),
  ];

  // ===== BREAKPOINTS =====
  
  static const double breakpointMobile = 640.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1280.0;

  // ===== MAX WIDTHS =====
  
  static const double maxWidthContent = 1200.0;
  static const double maxWidthContainer = 1440.0;

  // ===== TRANSICIONES =====
  
  static const Duration transitionFast = Duration(milliseconds: 150);
  static const Duration transitionBase = Duration(milliseconds: 220);
  static const Duration transitionSlow = Duration(milliseconds: 350);

  // ===== TAMAÑOS DE BOTONES =====
  
  static const double buttonHeightMin = 48.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;

  // ===== TAMAÑOS DE CARDS =====
  
  static const double cardAspectRatioWide = 16 / 9;
  static const double cardHeightMobile = 270.0;
  static const double cardHeightDesktop = 300.0;

  // ===== UTILIDADES =====

  /// TextStyle para H1
  static TextStyle textH1({
    Color color = ink900,
    FontWeight weight = weightSemibold,
  }) {
    return TextStyle(
      fontSize: fontSizeH1,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacingBase,
      height: lineHeightTight,
    );
  }

  /// TextStyle para H2
  static TextStyle textH2({
    Color color = ink900,
    FontWeight weight = weightSemibold,
  }) {
    return TextStyle(
      fontSize: fontSizeH2,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacingBase,
      height: lineHeightTight,
    );
  }

  /// TextStyle para H3
  static TextStyle textH3({
    Color color = ink900,
    FontWeight weight = weightSemibold,
  }) {
    return TextStyle(
      fontSize: fontSizeH3,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacingBase,
      height: lineHeightTight,
    );
  }

  /// TextStyle para Body
  static TextStyle textBody({
    Color color = ink700,
    FontWeight weight = weightRegular,
    double lineHeight = lineHeightBase,
  }) {
    return TextStyle(
      fontSize: fontSizeBody,
      fontWeight: weight,
      color: color,
      height: lineHeight,
    );
  }

  /// TextStyle para Body Small
  static TextStyle textBodySmall({
    Color color = ink700,
    FontWeight weight = weightRegular,
  }) {
    return TextStyle(
      fontSize: fontSizeBodySmall,
      fontWeight: weight,
      color: color,
      height: lineHeightBase,
    );
  }

  /// TextStyle para Caption
  static TextStyle textCaption({
    Color color = ink500,
    FontWeight weight = weightRegular,
  }) {
    return TextStyle(
      fontSize: fontSizeCaption,
      fontWeight: weight,
      color: color,
      height: lineHeightBase,
    );
  }

  /// TextStyle para Label
  static TextStyle textLabel({
    Color color = ink700,
    FontWeight weight = weightSemibold,
  }) {
    return TextStyle(
      fontSize: fontSizeLabel,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.5,
    );
  }
}
