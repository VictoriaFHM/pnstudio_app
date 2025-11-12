import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Card reutilizable para mostrar sectores con imagen
/// 
/// Características:
/// - Imagen a full width con aspectRatio 16:9
/// - Título (16px bold) y subtítulo (14px ink-500)
/// - Hover: zoom imagen 1.10, levantación de sombra, borde
/// - Transiciones suaves 220ms
class SectorCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isSelected;

  const SectorCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<SectorCard> createState() => _SectorCardState();
}

class _SectorCardState extends State<SectorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DesignTokens.transitionBase,
          decoration: BoxDecoration(
            color: DesignTokens.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            border: Border.all(
              color: _isHovered || widget.isSelected
                  ? DesignTokens.olive200
                  : DesignTokens.transparent,
              width: 1,
            ),
            boxShadow: _isHovered
                ? DesignTokens.shadowHover
                : widget.isSelected
                    ? DesignTokens.shadowLg
                    : DesignTokens.shadowMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen con zoom en hover
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignTokens.radiusXl),
                ),
                child: AspectRatio(
                  aspectRatio: DesignTokens.cardAspectRatioWide,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: AnimatedScale(
                          scale: _isHovered ? 1.10 : 1.0,
                          duration: DesignTokens.transitionBase,
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                Container(
                              color: DesignTokens.sand100,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: DesignTokens.ink500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Overlay sutil en hover
                      if (_isHovered)
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: DesignTokens.transitionBase,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  DesignTokens.transparent,
                                  DesignTokens.ink900.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Contenido (texto)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingLg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: DesignTokens.textBodySmall(
                          color: DesignTokens.ink900,
                          weight: DesignTokens.weightBold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignTokens.spacingSm),
                      Text(
                        widget.subtitle,
                        style: DesignTokens.textCaption(
                          color: DesignTokens.ink500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
