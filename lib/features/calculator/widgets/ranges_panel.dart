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

            final hasRecommended =
                resp.recommendedRl != null ||
                resp.etaAtRec != null ||
                resp.pAtRec != null;

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

                // Feasible banner (thinner) — use theme colors, no opacity
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: resp.feasible
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: resp.feasible
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'Factible: ${resp.feasible ? "Sí" : "No"}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: resp.feasible
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Table matrix for perfect alignment
                LayoutBuilder(
                  builder: (context, constraints) {
                    // final width = constraints.maxWidth; // not needed here

                    // Helper to create a mini chip
                    Widget mini(String text) => _MiniChip(text);

                    // Cells for rows
                    final pmaxCell = mini(
                      'Pmax [W]: ${_fmtNum(resp.pmax, frac: 4)}',
                    );
                    final pminCell = mini(
                      'P min [W]: ${_fmtNum(resp.pMin, frac: 4)}',
                    );
                    final pRecCell = resp.pAtRec != null
                        ? mini(
                            'P recomendado [W]: ${_fmtNum(resp.pAtRec, frac: 4)}',
                          )
                        : const SizedBox.shrink();

                    final etaMaxCell = mini('η max: ${fmtEtaPct(resp.etaMax)}');
                    final etaMinCell = mini('η min: ${fmtEtaPct(resp.etaMin)}');
                    final etaRecCell = resp.etaAtRec != null
                        ? mini('η recomendado: ${fmtEtaPct(resp.etaAtRec!)}')
                        : const SizedBox.shrink();

                    final rlMaxCell = mini(
                      'RL max [Ω]: ${_fmtNum(resp.rlMax)}',
                    );
                    final rlMinCell = mini(
                      'RL min [Ω]: ${_fmtNum(resp.rlMin)}',
                    );
                    final rlRecCell = resp.recommendedRl != null
                        ? mini(
                            'RL recomendado [Ω]: ${_fmtNum(resp.recommendedRl)}',
                          )
                        : const SizedBox.shrink();

                    // Pmax(k) row
                    final pMaxKChip = mini(
                      'P max (por k) [W]: ${_fmtNum(resp.pMaxByK, frac: 4)}',
                    );

                    // Short explanation
                    final explanation = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Potencia en el punto fijado por k. Compárala con Pmax.',
                        style: textTheme.labelMedium,
                      ),
                    );

                    // Build Table rows
                    final rows = <TableRow>[];

                    // Header row
                    rows.add(
                      TableRow(
                        children: [
                          _HeaderCellCompact('POTENCIAS', t),
                          _HeaderCellCompact('EFICIENCIAS', t),
                          _HeaderCellCompact('RESISTENCIAS', t),
                        ],
                      ),
                    );

                    // Maximos
                    rows.add(
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Center(child: pmaxCell),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Center(child: etaMaxCell),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Center(child: rlMaxCell),
                          ),
                        ],
                      ),
                    );

                    // Minimos
                    rows.add(
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 6),
                            child: Center(child: pminCell),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 6),
                            child: Center(child: etaMinCell),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 6),
                            child: Center(child: rlMinCell),
                          ),
                        ],
                      ),
                    );

                    // Recomended row (only if any exists)
                    if (hasRecommended) {
                      rows.add(
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 6),
                              child: Center(child: pRecCell),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 6),
                              child: Center(child: etaRecCell),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6, bottom: 6),
                              child: Center(child: rlRecCell),
                            ),
                          ],
                        ),
                      );
                    }

                    // Pmax(k) row: left cell chip, right cells explanation (spanned)
                    // pMaxByK is always present in ComputeResponse; show the row
                    {
                      rows.add(
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Center(child: pMaxKChip),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.top,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: explanation,
                                ),
                              ),
                            ),
                            const SizedBox.shrink(), // empty since explanation visually spans cols 1..2
                          ],
                        ),
                      );
                    }

                    return Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: rows,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Compact header cell
class _HeaderCellCompact extends StatelessWidget {
  final String text;
  final TextTheme t;
  const _HeaderCellCompact(this.text, this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: t.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Small mini chip used throughout the table
class _MiniChip extends StatelessWidget {
  final String label;
  const _MiniChip(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant, // active background
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: t.labelLarge?.copyWith(
          fontSize: 13,
          height: 1.15,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
