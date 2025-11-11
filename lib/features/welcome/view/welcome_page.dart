import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../widgets/intro_teorema_card.dart';
import '../widgets/about_app_card.dart';
import '../widgets/circuit_reference_card.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'NPStudio',
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 1024;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Teorema de Máxima Transferencia de Potencia',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Dos tarjetas lado a lado en pantallas anchas (≥1024px); en columna en móvil
                isWide
                    ? SizedBox(
                        height: 280,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: const [
                            Expanded(child: IntroTeoremaCard()),
                            SizedBox(width: 20),
                            Expanded(child: AboutAppCard()),
                          ],
                        ),
                      )
                    : const Column(
                        children: [
                          IntroTeoremaCard(),
                          SizedBox(height: 16),
                          AboutAppCard(),
                        ],
                      ),
                const SizedBox(height: 24),

                const CircuitReferenceCard(),
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/mode'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('Comenzar a calcular'),
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
