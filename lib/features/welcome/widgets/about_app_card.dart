import 'package:flutter/material.dart';

class AboutAppCard extends StatelessWidget {
  const AboutAppCard({super.key});

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
              '¿Para qué sirve esta página?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              'Aquí ingresás Vth y Rth, elegís cómo modelar pérdidas (k - eficiencia'
              'y c - potencia, ya sea en valor directo o en porcentaje) y la app calcula: '
              'rango de RL recomendado, potencia y eficiencia estimadas. '
              'Luego te mostramos la gráfica P vs RL y las recomendaciones.',
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
