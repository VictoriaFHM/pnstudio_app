import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// compact layout; spacing constants not required here
import 'package:pnstudio_app/data/models/compute_response.dart';

class RangesPanel extends StatelessWidget {
  final AsyncValue<ComputeResponse?> result;
  const RangesPanel({super.key, required this.result});

  String _fmtNum(num? v, {int frac = 3}) {
    if (v == null) return ''; // we'll not render nulls
    return v.toStringAsFixed(frac);
  }

  String fmtEtaPct(double v) => "${(v * 100).toStringAsFixed(1)}%";

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(12), // more compact
        child: result.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resultados',
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('Ocurrió un error al calcular:', style: t.titleMedium),
              const SizedBox(height: 6),
              Text('$e', style: t.bodyMedium),
            ],
          ),
          data: (resp) {
            if (resp == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados',
                    style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text('Aún no has calculado nada.'),
                ],
              );
            }

      // whether any recommended values exist (not used directly here anymore)
      // keep for potential future logic: recommended RL/eta/p

            final theme = Theme.of(context);
            final textTheme = theme.textTheme;
            final titleStyle = textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: theme.colorScheme.onSurface,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (compact but visible)
                Text('Resultados', style: titleStyle),
                const SizedBox(height: 8),

                    // Compact feasibility banner on top
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: resp.feasible ? const Color(0xFFEDF2E0) : theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: resp.feasible ? const Color(0xFF799351) : theme.colorScheme.error,
                          width: resp.feasible ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (resp.feasible) ...[
                            Icon(Icons.check_circle, color: const Color(0xFF799351), size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            'Factible: ${resp.feasible ? "Sí" : "No"}',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: resp.feasible ? const Color(0xFF2B3A21) : theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),

                const SizedBox(height: 10),

                // Responsive layout: for wide screens (>=1024) render three fixed columns
                LayoutBuilder(builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  const outerPadding = 12.0;
                  const spacing = 12.0;
                  const itemHeight = 68.0;

                  // Build the data values but keep original formatting/logic
                  final pmaxVal = _fmtNum(resp.pmax, frac: 3);
                  final pminVal = _fmtNum(resp.pMin, frac: 3);
                  final pRecVal = resp.pAtRec != null ? _fmtNum(resp.pAtRec, frac: 3) : '';
                  final pKVal = _fmtNum(resp.pMaxByK, frac: 3);

                  final etaMaxVal = '${(resp.etaMax * 100).toStringAsFixed(1)}%';
                  final etaMinVal = '${(resp.etaMin * 100).toStringAsFixed(1)}%';
                  final etaRecVal = resp.etaAtRec != null ? '${(resp.etaAtRec! * 100).toStringAsFixed(1)}%' : '';

                  final rlMaxVal = _fmtNum(resp.rlMax, frac: 2);
                  final rlMinVal = _fmtNum(resp.rlMin, frac: 2);
                  final rlRecVal = resp.recommendedRl != null ? _fmtNum(resp.recommendedRl, frac: 2) : '';

                  if (maxW >= 1024) {
                    // Three fixed columns by category (Potencia | Eficiencia | Resistencias)
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: outerPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 1 - Potencia (4 rows)
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(height: 0),
                                SizedBox(height: 0),
                                _ResultCard(item: _ResultItem(label: 'Pmax (W)', value: pmaxVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'P min (W)', value: pminVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'P recomendada (W)', value: pRecVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'Pₖ (W)', value: pKVal, tooltip: 'Potencia útil al operar con eficiencia objetivo k. Compárala con Pₘₐₓ.')),
                              ],
                            ),
                          ),
                          const SizedBox(width: spacing),

                          // Column 2 - Eficiencia (3 rows)
                          Expanded(
                            child: Column(
                              children: [
                                _ResultCard(item: _ResultItem(label: 'η max (%)', value: etaMaxVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'η min (%)', value: etaMinVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'η recomendada (%)', value: etaRecVal)),
                              ],
                            ),
                          ),
                          const SizedBox(width: spacing),

                          // Column 3 - Resistencias (3 rows)
                          Expanded(
                            child: Column(
                              children: [
                                _ResultCard(item: _ResultItem(label: 'RL max (Ω)', value: rlMaxVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'RL min (Ω)', value: rlMinVal)),
                                const SizedBox(height: spacing),
                                _ResultCard(item: _ResultItem(label: 'RL recomendado (Ω)', value: rlRecVal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Fallback: responsive wrap for narrower screens
                  final cols = maxW >= 900 ? 3 : (maxW >= 600 ? 2 : 1);
                  final available = maxW - outerPadding * 2 - spacing * (cols - 1);
                  final itemWidth = (available / cols).clamp(120.0, double.infinity);
                  final items = <_ResultItem>[
                    _ResultItem(label: 'Pmax (W)', value: pmaxVal),
                    _ResultItem(label: 'P min (W)', value: pminVal),
                    _ResultItem(label: 'P recomendada (W)', value: pRecVal),
                    _ResultItem(label: 'Pₖ (W)', value: pKVal, tooltip: 'Potencia útil al operar con eficiencia objetivo k. Compárala con Pₘₐₓ.'),
                    _ResultItem(label: 'η max (%)', value: etaMaxVal),
                    _ResultItem(label: 'η min (%)', value: etaMinVal),
                    _ResultItem(label: 'η recomendada (%)', value: etaRecVal),
                    _ResultItem(label: 'RL min (Ω)', value: rlMinVal),
                    _ResultItem(label: 'RL max (Ω)', value: rlMaxVal),
                    _ResultItem(label: 'RL recomendado (Ω)', value: rlRecVal),
                  ];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: outerPadding),
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: items
                          .map((it) => SizedBox(
                                width: itemWidth,
                                height: itemHeight,
                                child: _ResultCard(item: it),
                              ))
                          .toList(),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Data holder for a single result card
class _ResultItem {
  final String label;
  final String value;
  final String? tooltip;
  const _ResultItem({required this.label, required this.value, this.tooltip});
}

// Card widget used in the responsive results grid
class _ResultCard extends StatelessWidget {
  final _ResultItem item;
  const _ResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(fontSize: 13, color: theme.colorScheme.onSurfaceVariant);
    final valueStyle = theme.textTheme.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E1D8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: labelStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.tooltip != null) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: item.tooltip!,
                        child: Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
