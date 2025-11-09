import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pnstudio_app/core/constants/spacing.dart';
import 'package:pnstudio_app/core/widgets/section_title.dart';
import 'package:pnstudio_app/data/models/compute_response.dart';

class RangesPanel extends StatelessWidget {
  final AsyncValue<ComputeResponse?> result;
  const RangesPanel({super.key, required this.result});

  String _fmtNum(num? v, {int frac = 3}) {
    if (v == null) return '—';
    return v.toStringAsFixed(frac);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.lg),
        child: result.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(text: 'Rangos / Recomendaciones'),
              const SizedBox(height: Gaps.md),
              Text('Ocurrió un error al calcular:', style: t.titleSmall),
              const SizedBox(height: Gaps.xs),
              Text('$e', style: t.bodyMedium),
            ],
          ),
          data: (resp) {
            if (resp == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SectionTitle(text: 'Rangos / Recomendaciones'),
                  SizedBox(height: Gaps.md),
                  Text('Aún no has calculado nada.'),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(text: 'Rangos / Recomendaciones'),
                const SizedBox(height: Gaps.md),
                Wrap(
                  spacing: Gaps.lg,
                  runSpacing: Gaps.sm,
                  children: [
                    _ChipKV('Factible', resp.feasible ? 'Sí' : 'No'),
                    _ChipKV('Pmax [W]', _fmtNum(resp.pmax, frac: 4)),
                    _ChipKV('RL min [Ω]', _fmtNum(resp.rlMin)),
                    _ChipKV('RL max [Ω]', _fmtNum(resp.rlMax)),
                    _ChipKV('η min', _fmtNum(resp.etaMin)),
                    _ChipKV('η max', _fmtNum(resp.etaMax)),
                    _ChipKV('P min [W]', _fmtNum(resp.pMin, frac: 4)),
                    _ChipKV(
                      'P max (por k) [W]',
                      _fmtNum(resp.pMaxByK, frac: 4),
                    ),
                    _ChipKV('RL recomendado [Ω]', _fmtNum(resp.recommendedRl)),
                    _ChipKV('η en recomendado', _fmtNum(resp.etaAtRec)),
                    _ChipKV(
                      'P en recomendado [W]',
                      _fmtNum(resp.pAtRec, frac: 4),
                    ),
                  ],
                ),
                const SizedBox(height: Gaps.md),
                Text(
                  'Consejo: la potencia máxima se da típicamente cuando RL ≈ Rth en el caso ideal. '
                  'Aquí usamos tu modelo (k, c) y recomendación concreta del backend.',
                  style: t.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChipKV extends StatelessWidget {
  final String k;
  final String v;
  const _ChipKV(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$k: $v'));
  }
}
