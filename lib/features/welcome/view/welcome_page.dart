import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../widgets/intro_teorema_card.dart';
import '../widgets/about_app_card.dart';
// circuit_reference_card not used after refactor

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 1024;
          // Alturas compactas para desktop (1366x768)
          const rowCardHeight = 220.0; // Reducido de 280
          const imageCardHeight = 200.0; // Compacto para imágenes

          Widget buildRow(Widget left, Widget right, {double height = rowCardHeight}) {
            if (isWide) {
              return SizedBox(
                height: height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 16), // Reducido de 20
                    Expanded(child: right),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                left,
                const SizedBox(height: 12), // Reducido de 16
                right,
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Teorema de Máxima Transferencia de Potencia',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // Top info cards
                buildRow(const IntroTeoremaCard(), const AboutAppCard()),
                const SizedBox(height: 12),

                // Bottom image cards
                buildRow(
                  const _ImageCard(
                    title: 'Circuito de referencia',
                    assetPath: 'assets/images/circuit_reference.png',
                  ),
                  const _ImageCard(
                    title: 'P vs RL (máximo en RL = RTh)',
                    assetPath: 'assets/images/p_vs_rl.png',
                  ),
                  height: imageCardHeight,
                ),

                const SizedBox(height: 12),

                // CTA Button
                Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/guide'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Text('Elegir eficiencia y potencia'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Small internal image card used by the landing grid
class _ImageCard extends StatelessWidget {
  final String title;
  final String assetPath;

  const _ImageCard({required this.title, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.white, // Fondo blanco uniforme
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stack) {
                      return Center(
                        child: Text(
                          'No se pudo cargar:\n$assetPath',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
