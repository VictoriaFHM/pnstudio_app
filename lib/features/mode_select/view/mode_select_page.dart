import 'package:go_router/go_router.dart';
import '../models/input_mode.dart';
import 'package:flutter/material.dart';

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key});

  void _goToCalc(BuildContext context, InputMode mode) {
    context.push('/calc', extra: mode); // <- pasa el modo a /calc
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget chip(String text, IconData icon, InputMode m) => InkWell(
      onTap: () => _goToCalc(context, m),
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        avatar: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(text, style: t.titleMedium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('¿Cómo quieres ingresar los datos?')),
      body: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            // Show only the porcentajes option. Keep the other chips in the tree but hidden.
            InkWell(
              onTap: () => context.push('/calc?mode=percent'),
              borderRadius: BorderRadius.circular(20),
              child: Chip(
                avatar: const Icon(Icons.percent),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('Porcentajes (k%, c%)', style: t.titleMedium),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            // Hidden but kept in widget tree
            Offstage(offstage: true, child: chip('Valores exactos (k, c)', Icons.tune, InputMode.exacto)),
            Offstage(offstage: true, child: chip('Básico (Vth, Rth, Pmin)', Icons.flash_on, InputMode.basico)),
          ],
        ),
      ),
    );
  }
}
