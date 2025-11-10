import 'package:flutter/material.dart';

class CircuitReferenceCard extends StatelessWidget {
  const CircuitReferenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 700;
            final children = [
              _RefImage(
                title: 'Circuito de referencia',
                assetPath: 'assets/images/circuit_reference.png',
                maxHeight: 160,
              ),
              const SizedBox(width: 16, height: 16),
              _RefImage(
                title: 'P vs RL (máximo en RL = RTh)',
                assetPath: 'assets/images/p_vs_rl.png',
                maxHeight: 160,
              ),
            ];

            return isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  );
          },
        ),
      ),
    );
  }
}

class _RefImage extends StatelessWidget {
  final String title;
  final String assetPath;
  final double maxHeight;

  const _RefImage({
    required this.title,
    required this.assetPath,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Container(
                  alignment: Alignment.center,
                  height: maxHeight,
                  color: Colors.black12,
                  child: Text(
                    'No se pudo cargar:\n$assetPath',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
