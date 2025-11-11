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
          // card heights for desktop rows
          const rowCardHeight = 280.0;

          Widget buildRow(Widget left, Widget right) {
            if (isWide) {
              return SizedBox(
                height: rowCardHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 20),
                    Expanded(child: right),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                left,
                const SizedBox(height: 16),
                right,
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'TEOREMA DE MÁXIMA TRANSFERENCIA DE POTENCIA',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),

                // Top info cards (¿Qué es? / ¿Para qué sirve?)
                buildRow(const IntroTeoremaCard(), const AboutAppCard()),
                const SizedBox(height: 24),

                // Bottom image cards (two cards, same size)
                buildRow(
                  const _ImageCard(
                    title: 'Circuito de referencia',
                    assetPath: 'assets/images/circuit_reference.png',
                  ),
                  const _ImageCard(
                    title: 'P vs RL (máximo en RL = RTh)',
                    assetPath: 'assets/images/p_vs_rl.png',
                  ),
                ),

                const SizedBox(height: 32),

                // Bottom CTA centered — open sector guide
                Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/guide'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.black12,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) {
                      // Print to console and show a simple placeholder
                      debugPrint('No se pudo cargar la imagen');
                      return const Center(
                        child: Text('No se pudo cargar la imagen'),
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
