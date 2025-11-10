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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '¿Qué es?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              // ✅ “media” (conciso y técnico)
              'El teorema de máxima transferencia de potencia establece que la potencia máxima entregada'
              'a una carga ocurre cuando la resistencia de carga (Rl) es igual a la resistencia de'
              'la fuente (Rs) en circuitos de CC, o cuando la impedancia de carga (Zl) es'
              'el conjugado complejo de la impedancia de la fuente (Zs) en circuitos de CA.'
              'Este teorema es fundamental en el diseño de circuitos para aplicaciones como'
              'sistemas de comunicación, audio y arranque de automóviles.'
              'La eficiencia final dependerá del modelo (k, c).',
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
