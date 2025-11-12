import 'package:flutter/material.dart';

class AboutAppCard extends StatelessWidget {
  const AboutAppCard({super.key});

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
              '¿Para qué sirve esta página?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10),
            Text(
              'En esta página podés simular tu circuito equivalente de Thevenin.\n\nIngresás Vth y Rth, elegís cómo modelar las pérdidas mediante los parámetros k (eficiencia) y c (potencia disponible), y la app calcula el rango de RL que cumple con esas condiciones.\n\nLuego te mostramos la curva P vs RL y un valor recomendado de resistencia de carga para trabajar cerca de la máxima potencia con la eficiencia que fijaste.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
