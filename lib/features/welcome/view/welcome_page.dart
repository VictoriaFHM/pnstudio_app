import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/constants/spacing.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppScaffold(
      title: '¡Bienvenido a PnStudio!',
      body: Padding(
        padding: const EdgeInsets.all(Gaps.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Teorema de Máxima Transferencia de Potencia',
              style: t.headlineMedium,
            ),
            const SizedBox(height: Gaps.md),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: '¿Qué es?',
                    body:
                        'Cuando RL = RTh, la potencia en la carga es máxima. '
                        'La eficiencia final dependerá de k y c.',
                  ),
                ),
                const SizedBox(width: Gaps.md),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Gaps.md),
                      child: Image.asset(
                        'assets/images/circuit_reference.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Text('Sube circuit_reference.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Gaps.lg),
            SizedBox(
              height: 160,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Gaps.md),
                  child: Image.asset(
                    'assets/images/p_vs_rl.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Text('Sube p_vs_rl.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Gaps.lg),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () => context.go('/mode'),
                child: const Text('Comenzar a calcular'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
