import 'package:flutter/material.dart';

class IntroTeoremaCard extends StatelessWidget {
  const IntroTeoremaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              '¿Qué es?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10),
            Text(
              // ✅ Nuevo texto mejorado y técnico
              'El teorema de máxima transferencia de potencia establece que una fuente entrega la máxima potencia a la carga cuando la resistencia de carga (RL) es igual a la resistencia interna o de Thevenin (Rth).\n\nEste criterio se usa al diseñar etapas de salida en sistemas de comunicación, audio y arranque de motores, donde interesa aprovechar al máximo la potencia disponible.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
