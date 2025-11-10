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
      title: 'PnStudio',
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;
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
                const SizedBox(height: 16),

                // Dos tarjetas lado a lado en pantallas anchas; en columna en móvil
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: IntroTeoremaCard()),
                          SizedBox(width: 16),
                          Expanded(child: AboutAppCard()),
                        ],
                      )
                    : const Column(
                        children: [
                          IntroTeoremaCard(),
                          SizedBox(height: 12),
                          AboutAppCard(),
                        ],
                      ),
                const SizedBox(height: 12),

                const CircuitReferenceCard(),
                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pushNamed('/mode'),
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
