import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:pnstudio_app/core/constants/spacing.dart';
import 'package:pnstudio_app/core/widgets/section_title.dart';
import 'package:pnstudio_app/data/models/compute_response.dart';

class ChartPanel extends ConsumerWidget {
  const ChartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(text: 'Gráfica P vs RL'),
            const SizedBox(height: Gaps.md),
            _ChartContent(),
          ],
        ),
      ),
    );
  }
}

class _ChartContent extends StatelessWidget {
  const _ChartContent();

  @override
  Widget build(BuildContext context) {
    // Este widget espera que lo uses pasando el AsyncValue desde fuera si lo prefieres.
    // Para mantenerlo simple, solo muestra un placeholder y unos ejes.
    // Si quieres alimentarlo con datos reales, pásale el AsyncValue<ComputeResponse?> como prop.

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 10,
          minY: 0,
          maxY: 10,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              spots: const [FlSpot(1, 2), FlSpot(5, 9), FlSpot(9, 2)],
              dotData: const FlDotData(show: true),
            ),
          ],
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
