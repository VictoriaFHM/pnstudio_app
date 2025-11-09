import 'package:flutter/material.dart';
import 'package:pnstudio_app/core/constants/spacing.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final Widget? trailing;
  const InfoCard({
    super.key,
    required this.title,
    required this.body,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.titleMedium),
            const SizedBox(height: Gaps.sm),
            Text(body, style: t.bodyMedium),
            if (trailing != null) ...[
              const SizedBox(height: Gaps.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
