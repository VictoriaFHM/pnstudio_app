import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncValue;

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/utils/validators.dart';

import '../../mode_select/models/input_mode.dart';
import '../../../data/repositories/compute_repository.dart';
import '../../../data/models/compute_request.dart';
import '../../../data/models/compute_response.dart';

import '../widgets/chart_panel.dart';
import '../widgets/ranges_panel.dart';
import '../widgets/sticky_help_drawer.dart';

/// ✅ Ahora es StatefulWidget y recibe el modo por constructor.
/// GoRouter la crea así: CalculatorPage(mode: mode)
class CalculatorPage extends StatefulWidget {
  final InputMode mode;
  const CalculatorPage({super.key, required this.mode});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _computeRepo = ComputeRepository();

  final _vth = TextEditingController();
  final _rth = TextEditingController();
  final _k = TextEditingController();
  final _kPercent = TextEditingController();
  final _c = TextEditingController();
  final _cPercent = TextEditingController();
  final _pMinW = TextEditingController();

  ComputeResponse? _result;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _vth.dispose();
    _rth.dispose();
    _k.dispose();
    _kPercent.dispose();
    _c.dispose();
    _cPercent.dispose();
    _pMinW.dispose();
    super.dispose();
  }

  double? _toDoubleOrNull(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  ComputeRequest _buildRequest() {
    final vth = double.parse(_vth.text.replaceAll(',', '.'));
    final rth = double.parse(_rth.text.replaceAll(',', '.'));
    final k = _toDoubleOrNull(_k.text);
    final kPercent = _toDoubleOrNull(_kPercent.text);
    final c = _toDoubleOrNull(_c.text);
    final cPercent = _toDoubleOrNull(_cPercent.text);
    final pMinW = _toDoubleOrNull(_pMinW.text);

    switch (widget.mode) {
      case InputMode.exacto:
        return ComputeRequest(vth: vth, rth: rth, k: k, c: c, pMinW: pMinW);
      case InputMode.porcentaje:
        return ComputeRequest(
          vth: vth,
          rth: rth,
          kPercent: kPercent,
          cPercent: cPercent,
          pMinW: pMinW,
        );
      case InputMode.basico:
        return ComputeRequest(vth: vth, rth: rth, pMinW: pMinW);
    }
  }

  Future<void> _onSubmit() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final ex1 = Validators.mutuallyExclusive(
        _k.text,
        _kPercent.text,
        'k',
        'k%',
      );
      final ex2 = Validators.mutuallyExclusive(
        _c.text,
        _cPercent.text,
        'c',
        'c%',
      );
      if (ex1 != null || ex2 != null) {
        setState(() {
          _loading = false;
          _error = ex1 ?? ex2;
        });
        return;
      }

      if (!_formKey.currentState!.validate()) {
        setState(() => _loading = false);
        return;
      }

      final req = _buildRequest();
      final res = await _computeRepo.compute(req);
      setState(() => _result = res);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  AsyncValue<ComputeResponse?> get _rangesAsync {
    if (_loading) return const AsyncValue.loading();
    if (_error != null) return AsyncValue.error(_error!, StackTrace.empty);
    return AsyncValue.data(_result);
  }

  @override
  Widget build(BuildContext context) {
    final showExact = widget.mode == InputMode.exacto;
    final showPercent = widget.mode == InputMode.porcentaje;

    return AppScaffold(
      title: 'Calculadora',
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;

          final form = Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _vth,
                  decoration: const InputDecoration(labelText: 'Vth (V) *'),
                  validator: (v) => Validators.requiredPositive(v),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextFormField(
                  controller: _rth,
                  decoration: const InputDecoration(labelText: 'Rth (Ω) *'),
                  validator: (v) => Validators.requiredPositive(v),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (showExact) ...[
                  TextFormField(
                    controller: _k,
                    decoration: const InputDecoration(labelText: 'k (0..1)'),
                    validator: Validators.cRange,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextFormField(
                    controller: _c,
                    decoration: const InputDecoration(labelText: 'c (0..1)'),
                    validator: Validators.cRange,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
                if (showPercent) ...[
                  TextFormField(
                    controller: _kPercent,
                    decoration: const InputDecoration(labelText: 'k% (0..100)'),
                    validator: (v) => Validators.kPercentRange(v),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextFormField(
                    controller: _cPercent,
                    decoration: const InputDecoration(labelText: 'c% (0..100)'),
                    validator: Validators.cPercentRange,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
                TextFormField(
                  controller: _pMinW,
                  decoration: const InputDecoration(labelText: 'P mínima (W)'),
                  validator: Validators.nonNegative,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _onSubmit,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Calcular'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          );

          final mainColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En pantallas anchas, formulario y gráfica lado a lado
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: form),
                    const SizedBox(width: 16),
                    const Expanded(flex: 6, child: ChartPanel()),
                  ],
                )
              else ...[
                form,
                const SizedBox(height: 12),
                const ChartPanel(),
              ],
              const SizedBox(height: 16),
              // Rangos / recomendación
              RangesPanel(result: _rangesAsync),
            ],
          );

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: mainColumn,
                ),
              ),
              const Positioned(
                right: 12,
                bottom: 12,
                child: StickyHelpDrawer(),
              ),
            ],
          );
        },
      ),
    );
  }
}
