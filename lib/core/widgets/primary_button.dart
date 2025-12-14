import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Botón primario unificado para toda la aplicación
///
/// Características:
/// - Color: verde oliva (#6B8E23)
/// - Hover: verde oliva oscuro (#5C7C1E)
/// - Shape: pill/stadium (radius 999)
/// - Altura mínima: 48px
/// - Sombra suave y transiciones suaves
class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? leadingIcon;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsets? padding;
  final Size? minimumSize;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.leadingIcon = Icons.arrow_forward_rounded,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      icon: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.white),
              ),
            )
          : Icon(leadingIcon),
      label: Text(
        label,
        style: DesignTokens.textBodySmall(
          color: DesignTokens.white,
          weight: DesignTokens.weightBold,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return DesignTokens.sand100;
          }
          if (states.contains(WidgetState.hovered)) {
            return DesignTokens.olive700;
          }
          return DesignTokens.olive600;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return DesignTokens.ink500;
          }
          return DesignTokens.white;
        }),
        padding: WidgetStateProperty.all(
          padding ??
              const EdgeInsets.symmetric(
                horizontal: DesignTokens.buttonPaddingHorizontal,
                vertical: DesignTokens.buttonPaddingVertical,
              ),
        ),
        minimumSize: WidgetStateProperty.all(
          minimumSize ??
              const Size(double.infinity, DesignTokens.buttonHeightMin),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.hovered)) {
            return 8.0;
          }
          if (states.contains(WidgetState.pressed)) {
            return 4.0;
          }
          return 4.0;
        }),
        shadowColor: WidgetStateProperty.all(
          const Color(0x26000000), // Sombra suave
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.focused)) {
            return DesignTokens.olive700.withOpacity(0.1);
          }
          return null;
        }),
      ),
    );
  }
}
