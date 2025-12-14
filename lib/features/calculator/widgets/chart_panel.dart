import 'dart:math';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
    if (result == null || !result!.feasible) return [];

    final rlMin = result!.rlMin;
    final rlMax = result!.rlMax;
    final pmax = result!.pmax;

    // Generamos 200+ puntos entre rlMin y rlMax para mayor precisión
    // Asumimos que P tiene un máximo alrededor de rlMin + (rlMax - rlMin)/2
    final numPoints = 200;
    final range = rlMax - rlMin;
    if (range <= 0) {
      // Degenerate range: produce a single point
      return [FlSpot(rlMin, pmax)];
    }
    final step = range / (numPoints - 1);
    final spots = <FlSpot>[];

    for (int i = 0; i < numPoints; i++) {
      final rl = rlMin + (i * step);
      // Modelo simple: parábola invertida con pico en Pmax
      // P(RL) ≈ Pmax * (1 - ((RL - Rth_equiv)^2 / maxDist))
      // Para simplificar: asumimos que el máximo está en el punto medio del rango
      final distFromMax = (rl - (rlMin + rlMax) / 2).abs();
      final maxDist = range / 2;
      final p =
          pmax *
          (1 - (distFromMax / maxDist) * (distFromMax / maxDist)).clamp(0, 1);
      spots.add(FlSpot(rl, p));
    }

    return spots;
  }

  /// Genera líneas verticales para rlMin, rlMax, y recommendedRl (si existe)
  /// Usa colores y estilos prominentes para énfasis
  List<VerticalLine> _buildVerticalLines() {
    if (result == null || !result!.feasible) return [];

    final lines = <VerticalLine>[];

    // RLmin: dashed marker (now styled to match requested emphasis)
    lines.add(
      VerticalLine(
        x: result!.rlMin,
        color: const Color(0xFF8C2E2E),
        strokeWidth: 3.0,
        dashArray: [4, 4],
        label: VerticalLineLabel(
          show: true,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(bottom: 8),
          labelResolver: (_) => 'RLmin',
          style: const TextStyle(
            color: Color(0xFF8C2E2E),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // RLmax: dashed marker
    lines.add(
      VerticalLine(
        x: result!.rlMax,
        color: const Color(0xFF8C2E2E),
        strokeWidth: 3.0,
        dashArray: [4, 4],
        label: VerticalLineLabel(
          show: true,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(bottom: 8),
          labelResolver: (_) => 'RLmax',
          style: const TextStyle(
            color: Color(0xFF8C2E2E),
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
            'Introduce los datos y presiona Calcular para generar la gráfica.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Color(0xFF707B50)),
          ),
        ),
      );
    }

    // Si no es factible, no mostrar gráfica
    if (!result!.feasible) {
      return SizedBox(
        height: 260,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No se puede generar la gráfica: los parámetros ingresados no son factibles.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
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

        // Compute a "nice" step for bottom axis to avoid overlap (approx 8 labels)
        final minX = result!.rlMin;
        final maxX = result!.rlMax;
        final dx = maxX - minX;
        double niceStep(double x) {
          if (x <= 0) return 1.0;
          final p = pow(10, (log(x) / ln10).floor()).toDouble();
          final n = x / p;
          final m = (n <= 1)
              ? 1
              : (n <= 2)
              ? 2
              : (n <= 5)
              ? 5
              : 10;
          return m * p;
        }

        final raw = dx / 8.0;
        final step = niceStep(raw);

        final chart = SizedBox(
          height: chartHeight,
          width: minChartWidth,
          child: Container(
            color: const Color(0xFFF7F5F0),
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
            child: LineChart(
              LineChartData(
                backgroundColor: const Color(0xFFF7F5F0),
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: result!.pmax * 1.1,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(3),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                    axisNameWidget: const Text(
                      'P (W)',
                      style: TextStyle(fontSize: 11),
                    ),
                    axisNameSize: 18,
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: step,
                      getTitlesWidget: (value, meta) {
                        // Only show labels aligned to step (avoid 233.5, etc.)
                        final rel = (value - minX) / step;
                        if ((rel - rel.round()).abs() > 1e-6) {
                          return const SizedBox.shrink();
                        }
                        final absStep = step.abs();
                        final decimals = absStep >= 1
                            ? 0
                            : (absStep >= 0.1 ? 1 : 2);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            value.toStringAsFixed(decimals),
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      },
                    ),
                    axisNameWidget: const Text(
                      'RL (Ω)',
                      style: TextStyle(fontSize: 11),
                    ),
                    axisNameSize: 18,
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: spots,
                    dotData: const FlDotData(show: false),
                    color: const Color(0xFF799351), // curve color (olive-ish)
                    barWidth: 2.5,
                  ),
                ],
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true),
                // Shaded feasible band between rlMin and rlMax (low opacity: 0.08)
                rangeAnnotations: RangeAnnotations(
                  verticalRangeAnnotations: [
                    VerticalRangeAnnotation(
                      x1: minX,
                      x2: maxX,
                      color: const Color(0xFF799351).withOpacity(0.08),
                    ),
                  ],
                ),
                // Vertical marker lines
                extraLinesData: ExtraLinesData(
                  verticalLines: _buildVerticalLines(),
                ),
                // Interactive touch tooltip: tap curve to see RL and P values
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final rl = touchedSpot.x.toStringAsFixed(1);
                        final p = touchedSpot.y.toStringAsFixed(3);
                        return LineTooltipItem(
                          'RL: $rl Ω\nP: $p W\n(factible)',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                clipData: FlClipData.none(),
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
