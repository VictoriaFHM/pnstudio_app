import 'package:flutter/material.dart';

class CircuitReferenceCard extends StatelessWidget {
  const CircuitReferenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/circuit_reference.png',
            fit: BoxFit.contain,
            height: 140,
          ),
        ),
      ),
    );
  }
}
