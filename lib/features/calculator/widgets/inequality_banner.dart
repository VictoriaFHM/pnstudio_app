import 'package:flutter/material.dart';
import '../utils/calculation_utils.dart';

enum BannerType { success, info, warning }

class InequalityBanner extends StatelessWidget {
  final double? k;
  final double? c;
  final double rlMin;
  final double rlMax;
  final bool feasible;

  const InequalityBanner({
    super.key,
    required this.k,
    required this.c,
    required this.rlMin,
    required this.rlMax,
    required this.feasible,
  });

  /// Determina qué tipo de banner mostrar
  (BannerType type, String text) _getBannerContent() {
    // Always render the inequality with 3 decimals
    final inequality = 'RL ∈ [${rlMin.toStringAsFixed(3)}, ${rlMax.toStringAsFixed(3)}] Ω';

    // If not feasible, show warning message
    if (!feasible) {
      return (BannerType.warning, 'Incompatible bajo RL > Rth: relajar k, relajar c o permitir RL < Rth');
    }

    // If c not provided, do not compute kcrit — just show inequality (success style)
    if (c == null) {
      return (BannerType.success, inequality);
    }

    // c provided — compute kcrit (c is non-null here)
    final kcrit = calculateKcrit(c!);

    // If k not provided, show inequality
    if (k == null) {
      return (BannerType.success, inequality);
    }

    final kVal = k!;

    // If k approximately equals kcrit
    if (isClose(kVal, kcrit)) {
      return (BannerType.info, 'Única solución: RL = ${rlMin.toStringAsFixed(3)} Ω');
    }

    // If k < kcrit and feasible → inequality
    if (kVal < kcrit) {
      return (BannerType.success, inequality);
    }

    // k > kcrit or other incompatible case
    return (BannerType.warning, 'Incompatible bajo RL > Rth: relajar k, relajar c o permitir RL < Rth');
  }

  Color _getColor(BannerType type) {
    switch (type) {
      case BannerType.success:
        return Colors.green.shade50;
      case BannerType.info:
        return Colors.blue.shade50;
      case BannerType.warning:
        return Colors.orange.shade50;
    }
  }

  Color _getBorderColor(BannerType type) {
    switch (type) {
      case BannerType.success:
        return Colors.green;
      case BannerType.info:
        return Colors.blue;
      case BannerType.warning:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bannerType, text) = _getBannerContent();
    final bgColor = _getColor(bannerType);
    final borderColor = _getBorderColor(bannerType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            bannerType == BannerType.success
                ? Icons.check_circle
                : bannerType == BannerType.info
                    ? Icons.info
                    : Icons.warning,
            color: borderColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: borderColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
