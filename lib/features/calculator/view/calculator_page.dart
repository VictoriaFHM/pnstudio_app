// lib/features/calculator/view/calculator_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pnstudio_app/core/constants/spacing.dart';
import 'package:pnstudio_app/core/widgets/app_scaffold.dart';
import 'package:pnstudio_app/data/models/compute_request.dart';
import 'package:pnstudio_app/features/mode_select/models/input_mode.dart';
import '../controller/calculator_controller.dart';
import '../widgets/data_form.dart';
import '../widgets/chart_panel.dart';
import '../widgets/ranges_panel.dart';
import '../widgets/sticky_help_drawer.dart';

class CalculatorPage extends ConsumerWidget {
  final InputMode mode;
  const CalculatorPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorControllerProvider(mode));
    final ctrl = ref.read(calculatorControllerProvider(mode).notifier);

    return AppScaffold(
      title: 'Cálculos • ${mode.label}',
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 980;

              final form = DataForm(
                mode: mode,
                busy: state.result.isLoading,
                onSubmit: (vth, rth, {k, kPercent, c, cPercent, pMinW}) async {
                  final req = ComputeRequest(
                    vth: vth,
                    rth: rth,
                    k: k,
                    kPercent: kPercent,
                    c: c,
                    cPercent: cPercent,
                    pMinW: pMinW,
                  );
                  final result = await ctrl.submit(
                    req,
                  ); // <- devuelve ComputeResponse?
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cálculo listo ✔')),
                    );
                  }
                },
              );

              final right = Column(
                children: [
                  const ChartPanel(),
                  const SizedBox(height: Gaps.lg),
                  RangesPanel(result: state.result),
                ],
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(Gaps.lg),
                        child: form,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(Gaps.lg),
                        child: right,
                      ),
                    ),
                  ],
                );
              } else {
                return ListView(
                  padding: const EdgeInsets.all(Gaps.lg),
                  children: [
                    form,
                    const SizedBox(height: Gaps.lg),
                    ...right.children,
                  ],
                );
              }
            },
          ),
          const StickyHelpDrawer(),
        ],
      ),
    );
  }
}
