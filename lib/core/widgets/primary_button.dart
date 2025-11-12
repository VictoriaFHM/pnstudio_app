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
    Key? key,
    required this.onPressed,
    required this.label,
    this.leadingIcon = Icons.arrow_forward_rounded,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding,
    this.minimumSize,
  }) : super(key: key);

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
                valueColor:
                    AlwaysStoppedAnimation<Color>(DesignTokens.white),
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
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return DesignTokens.sand100;
            }
            if (states.contains(MaterialState.hovered)) {
              return DesignTokens.olive700;
            }
            return DesignTokens.olive600;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return DesignTokens.ink500;
            }
            return DesignTokens.white;
          },
        ),
        padding: MaterialStateProperty.all(
          padding ??
              const EdgeInsets.symmetric(
                horizontal: DesignTokens.buttonPaddingHorizontal,
                vertical: DesignTokens.buttonPaddingVertical,
              ),
        ),
        minimumSize: MaterialStateProperty.all(
          minimumSize ??
              const Size(double.infinity, DesignTokens.buttonHeightMin),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          ),
        ),
        elevation: MaterialStateProperty.resolveWith<double>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return 8.0;
            }
            if (states.contains(MaterialState.pressed)) {
              return 4.0;
            }
            return 4.0;
          },
        ),
        shadowColor: MaterialStateProperty.all(
          const Color(0x26000000), // Sombra suave
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return DesignTokens.olive700.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
    );
  }
}
