import 'package:flutter/material.dart';

class IntroTeoremaCard extends StatelessWidget {
  const IntroTeoremaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              '¿Qué es?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              // ✅ “media” (conciso y técnico)
              'El teorema de máxima transferencia de potencia establece que la potencia máxima entregada'
              'a una carga ocurre cuando la resistencia de carga (RL) es igual a la resistencia de la fuente'
              ' (Rth) en circuitos de DC. Este teorema es fundamental en el diseño de circuitos para '
              'para aplicaciones como sistemas de comunicación, audio y arranque de automóviles.'
              ' La eficiencia final dependerá del modelo (k, c).',
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
