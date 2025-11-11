import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:pnstudio_app/core/constants/spacing.dart';
import 'package:pnstudio_app/core/widgets/section_title.dart';
import 'package:pnstudio_app/data/models/compute_response.dart';

class ChartPanel extends StatelessWidget {
  final ComputeResponse? result;
  final bool loading;
  const ChartPanel({super.key, this.result, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(text: 'Gráfica P vs RL'),
            const SizedBox(height: Gaps.md),
            _ChartContent(result: result, loading: loading),
          ],
        ),
      ),
    );
  }
}

class _ChartContent extends StatelessWidget {
  final ComputeResponse? result;
  final bool loading;
  const _ChartContent({this.result, this.loading = false});

  /// Genera spots para la gráfica P vs RL
  /// Basado en el rango [rlMin, rlMax] y modelando la parábola típica
  List<FlSpot> _generateSpots() {
    if (result == null) return [];
    
    final rlMin = result!.rlMin;
    final rlMax = result!.rlMax;
    final pmax = result!.pmax;
    
    // Generamos 200+ puntos entre rlMin y rlMax para mayor precisión
    // Asumimos que P tiene un máximo alrededor de rlMin + (rlMax - rlMin)/2
    final numPoints = 200;
    final step = (rlMax - rlMin) / (numPoints - 1);
    final spots = <FlSpot>[];
    
    for (int i = 0; i < numPoints; i++) {
      final rl = rlMin + (i * step);
      // Modelo simple: parábola invertida con pico en Pmax
      // P(RL) ≈ Pmax * (1 - ((RL - Rth_equiv)^2 / maxDist))
      // Para simplificar: asumimos que el máximo está en el punto medio del rango
      final distFromMax = (rl - (rlMin + rlMax) / 2).abs();
      final maxDist = (rlMax - rlMin) / 2;
      final p = pmax * (1 - (distFromMax / maxDist) * (distFromMax / maxDist)).clamp(0, 1);
      spots.add(FlSpot(rl, p));
    }
    
    return spots;
  }

  /// Genera líneas verticales para rlMin, rlMax, y recommendedRl (si existe)
  /// Usa colores y estilos prominentes para énfasis
  List<VerticalLine> _buildVerticalLines() {
    if (result == null) return [];
    
    final lines = <VerticalLine>[];
    
    // RLmin: dashed green (Color(0xFF2E7D32)), strokeWidth 3.0
    lines.add(
      VerticalLine(
        x: result!.rlMin,
        color: const Color(0xFF2E7D32),
        strokeWidth: 3.0,
        dashArray: [4, 4],
        label: VerticalLineLabel(
          show: true,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(bottom: 8),
          labelResolver: (_) => 'RLmin',
          style: const TextStyle(
            color: Color(0xFF2E7D32),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    
    // RLmax: dashed red (Color(0xFFB00020)), strokeWidth 3.0
    lines.add(
      VerticalLine(
        x: result!.rlMax,
        color: const Color(0xFFB00020),
        strokeWidth: 3.0,
        dashArray: [4, 4],
        label: VerticalLineLabel(
          show: true,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(bottom: 8),
          labelResolver: (_) => 'RLmax',
          style: const TextStyle(
            color: Color(0xFFB00020),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    
    // recommendedRl (if not null): dashed amber (Color(0xFFFF8F00)), strokeWidth 3.0
    if (result!.recommendedRl != null) {
      lines.add(
        VerticalLine(
          x: result!.recommendedRl!,
          color: const Color(0xFFFF8F00),
          strokeWidth: 3.0,
          dashArray: [3, 3],
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(bottom: 8),
            labelResolver: (_) => 'Rec.',
            style: const TextStyle(
              color: Color(0xFFFF8F00),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (result == null) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Text(
            'Calcula primero para ver la gráfica',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final spots = _generateSpots();
    if (spots.isEmpty) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Text(
            'No hay datos para mostrar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular altura responsiva:
        // - Pantalla ancha (>= 900px): 440-480px
        // - Pantalla estrecha (< 900px): 320-360px
        final screenWidth = constraints.maxWidth;
        double chartHeight;
        if (screenWidth >= 900) {
          // Desktop/Tablet: height = clamp(screenWidth * 0.38, 360, 480)
          chartHeight = (screenWidth * 0.38).clamp(360, 480);
        } else {
          // Mobile: 320-360px
          chartHeight = (screenWidth * 0.4).clamp(320, 360);
        }

        // Ancho mínimo del gráfico para garantizar espaciado de ticks
        final minChartWidth = screenWidth < 500 ? 600.0 : screenWidth;

        final chart = SizedBox(
          height: chartHeight,
          width: minChartWidth,
          child: LineChart(
            LineChartData(
              minX: result!.rlMin,
              maxX: result!.rlMax,
              minY: 0,
              maxY: result!.pmax * 1.1,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(3),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                  axisNameWidget: const Text('P (W)', style: TextStyle(fontSize: 11)),
                  axisNameSize: 18,
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                  axisNameWidget: const Text('RL (Ω)', style: TextStyle(fontSize: 11)),
                  axisNameSize: 18,
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: spots,
                  dotData: const FlDotData(show: false),
                  color: Colors.blue,
                  barWidth: 2.5,
                ),
              ],
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              // Shaded feasible band between rlMin and rlMax (low opacity: 0.08)
              rangeAnnotations: RangeAnnotations(
                verticalRangeAnnotations: [
                  VerticalRangeAnnotation(
                    x1: result!.rlMin,
                    x2: result!.rlMax,
                    color: Colors.green.withValues(alpha: 0.08),
                  ),
                ],
              ),
              // Vertical marker lines
              extraLinesData: ExtraLinesData(
                verticalLines: _buildVerticalLines(),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final feasible = result!.feasible &&
                          spot.x >= result!.rlMin &&
                          spot.x <= result!.rlMax;
                      return LineTooltipItem(
                        'RL: ${spot.x.toStringAsFixed(1)} Ω\nP: ${spot.y.toStringAsFixed(3)} W${feasible ? '\n(factible)' : ''}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );

        // Envolver en SingleChildScrollView si la pantalla es muy estrecha
        if (screenWidth < 500) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chart,
          );
        }

        return chart;
      },
    );
  }
}
