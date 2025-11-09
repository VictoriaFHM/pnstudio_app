import 'package:flutter/material.dart';
import 'package:pnstudio_app/core/constants/spacing.dart';

class StickyHelpDrawer extends StatelessWidget {
  const StickyHelpDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          right: Gaps.md,
          top: Gaps.lg,
          bottom: Gaps.lg,
        ),
        width: 280,
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(Gaps.md),
            child: const Text(
              '¿Para qué me sirve?\n\n'
              'El teorema de máxima transferencia de potencia te dice cómo elegir la carga RL '
              'para obtener la máxima potencia desde una fuente con resistencia interna Rth. '
              'Aquí calculamos rangos, recomendación y eficiencias con tu modelo (k, c).',
            ),
          ),
        ),
      ),
    );
  }
}
