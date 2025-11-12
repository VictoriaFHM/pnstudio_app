import 'package:flutter/material.dart';

/// Reusable section header used across screens (title, optional subtitle, olive divider)
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 20 : 28,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 72,
          decoration: BoxDecoration(color: const Color(0xFF6E8C1A), borderRadius: BorderRadius.circular(6)),
        ),
      ],
    );
  }
}
