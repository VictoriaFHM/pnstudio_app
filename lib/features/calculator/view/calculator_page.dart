import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncValue;
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
// utils moved parsing into local helpers

import '../../mode_select/models/input_mode.dart';
import '../../../data/repositories/compute_repository.dart';
import '../../../data/models/compute_request.dart';
import '../../../data/models/compute_response.dart';

import '../widgets/chart_panel.dart';
import '../widgets/ranges_panel.dart';
import '../widgets/inequality_banner.dart';

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
  // Focus nodes for scroll-to-first-invalid
  final _vthFocus = FocusNode();
  final _rthFocus = FocusNode();
  final _kFocus = FocusNode();
  final _kPercentFocus = FocusNode();
  final _cFocus = FocusNode();
  final _cPercentFocus = FocusNode();
  final _pMinWFocus = FocusNode();

  // enable/disable flags for mutually exclusive fields
  bool _kEnabled = true;
  bool _kPercentEnabled = true;
  bool _cEnabled = true;
  bool _cPercentEnabled = true;

  ComputeResponse? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // listeners to toggle mutually exclusive fields
    _k.addListener(() {
      final has = _k.text.trim().isNotEmpty;
      if (has) {
        if (_kPercentEnabled) setState(() => _kPercentEnabled = false);
      } else {
        if (!_kPercentEnabled) setState(() => _kPercentEnabled = true);
      }
    });
    _kPercent.addListener(() {
      final has = _kPercent.text.trim().isNotEmpty;
      if (has) {
        if (_kEnabled) setState(() => _kEnabled = false);
      } else {
        if (!_kEnabled) setState(() => _kEnabled = true);
      }
    });
    _c.addListener(() {
      final has = _c.text.trim().isNotEmpty;
      if (has) {
        if (_cPercentEnabled) setState(() => _cPercentEnabled = false);
      } else {
        if (!_cPercentEnabled) setState(() => _cPercentEnabled = true);
      }
    });
    _cPercent.addListener(() {
      final has = _cPercent.text.trim().isNotEmpty;
      if (has) {
        if (_cEnabled) setState(() => _cEnabled = false);
      } else {
        if (!_cEnabled) setState(() => _cEnabled = true);
      }
    });
    // initial states
    _kEnabled = _k.text.trim().isEmpty;
    _kPercentEnabled = _kPercent.text.trim().isEmpty;
    _cEnabled = _c.text.trim().isEmpty;
    _cPercentEnabled = _cPercent.text.trim().isEmpty;
  }

  @override
  void dispose() {
    _vth.dispose();
    _rth.dispose();
    _k.dispose();
    _kPercent.dispose();
    _c.dispose();
    _cPercent.dispose();
    _pMinW.dispose();
    _vthFocus.dispose();
    _rthFocus.dispose();
    _kFocus.dispose();
    _kPercentFocus.dispose();
    _cFocus.dispose();
    _cPercentFocus.dispose();
    _pMinWFocus.dispose();
    super.dispose();
  }

  bool isEmpty(String? s) => s == null || s.trim().isEmpty;

  // Helper de parseo seguro solicitado
  double? _toDoubleOrNull(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  /// Obtiene el valor actual de k según el modo (nullable)
  double? _getKNullable() {
    if (widget.mode == InputMode.exacto) {
      return _toDoubleOrNull(_k.text);
    }
    if (widget.mode == InputMode.porcentaje) {
      final kPct = _toDoubleOrNull(_kPercent.text);
      return kPct == null ? null : (kPct / 100.0);
    }
    return null;
  }

  /// Obtiene el valor actual de c según el modo (nullable)
  double? _getCNullable() {
    if (widget.mode == InputMode.exacto) {
      return _toDoubleOrNull(_c.text);
    }
    if (widget.mode == InputMode.porcentaje) {
      final cPct = _toDoubleOrNull(_cPercent.text);
      return cPct == null ? null : (cPct / 100.0);
    }
    return null;
  }

  // _buildRequest removed: building ComputeRequest now performed inline in _onSubmit

  Future<void> _onSubmit() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      // Validate form fields first
      if (!_formKey.currentState!.validate()) {
        setState(() => _loading = false);
        return;
      }

      // Basic required parsing (validators ensured non-null)
      final vth = _toDoubleOrNull(_vth.text)!;
      final rth = _toDoubleOrNull(_rth.text)!;

      // For percentage mode validate k% exists
      if (widget.mode == InputMode.porcentaje) {
        // Validators ensure both k% and c% are present and in range for this screen
        final kPctNullable = _toDoubleOrNull(_kPercent.text);
        final cPctNullable = _toDoubleOrNull(_cPercent.text);
        if (kPctNullable == null || cPctNullable == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa eficiencia (%) y potencia (%)')));
          setState(() => _loading = false);
          return;
        }

        // Build request with ONLY the required fields for porcentaje mode
  final req = ComputeRequest(vth: vth, rth: rth, kPercent: kPctNullable, cPercent: cPctNullable);
        final res = await _computeRepo.compute(req);
        setState(() => _result = res);
      } else if (widget.mode == InputMode.exacto) {
        // exact mode: parse k and c as exact values; require one of them? we rely on existing validators
  final kVal = _toDoubleOrNull(_k.text);
  final cVal = _toDoubleOrNull(_c.text);
  final pMin = _toDoubleOrNull(_pMinW.text);

        // If both c and pMin missing, backend requires at least one; enforce here
        if (cVal == null && pMin == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes ingresar c o P mínima (W)')));
          setState(() => _loading = false);
          return;
        }

        final req = ComputeRequest(vth: vth, rth: rth, k: kVal, c: cVal, pMinW: pMin);
        final res = await _computeRepo.compute(req);
        setState(() => _result = res);
      } else {
        // basico
  final pMin = _toDoubleOrNull(_pMinW.text);
        if (pMin == null) {
          // backend requires c/cPercent or pMinW; here ask user to provide pMinW
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes ingresar c% o P mínima (W)')));
          setState(() => _loading = false);
          return;
        }
        final req = ComputeRequest(vth: vth, rth: rth, pMinW: pMin);
        final res = await _computeRepo.compute(req);
        setState(() => _result = res);
      }
    } catch (e) {
      // Surface backend validation errors clearly
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  // _focusFirstInvalid removed — validation handled inline in _onSubmit using SnackBars

  AsyncValue<ComputeResponse?> get _rangesAsync {
    if (_loading) return const AsyncValue.loading();
    if (_error != null) return AsyncValue.error(_error!, StackTrace.empty);
    return AsyncValue.data(_result);
  }

  @override
  Widget build(BuildContext context) {
    final showExact = widget.mode == InputMode.exacto;
    final showPercent = widget.mode == InputMode.porcentaje;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;

          final form = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado "Datos"
                Text(
                  'Datos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vth,
                  focusNode: _vthFocus,
                  decoration: const InputDecoration(
                    labelText: 'Vth (V) *',
                    helperText: 'Obligatorio — > 0',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                    final x = double.tryParse(v.replaceAll(',', '.'));
                    if (x == null) return 'Número inválido';
                    if (x <= 0) return 'Debe ser > 0';
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                TextFormField(
                  controller: _rth,
                  focusNode: _rthFocus,
                  decoration: const InputDecoration(
                    labelText: 'Rth (Ω) *',
                    helperText: 'Obligatorio — > 0',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                    final x = double.tryParse(v.replaceAll(',', '.'));
                    if (x == null) return 'Número inválido';
                    if (x <= 0) return 'Debe ser > 0';
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (showExact) ...[
                  TextFormField(
                    controller: _k,
                    focusNode: _kFocus,
                    enabled: _kEnabled,
                      decoration: const InputDecoration(
                        labelText: 'k (eficiencia, 0..1)',
                        helperText: 'Rango: 0..1',
                      ),
                    validator: (v) {
                      final otherHas = _kPercent.text.trim().isNotEmpty;
                      if (v == null || v.trim().isEmpty) {
                        if (!otherHas) return 'Campo obligatorio';
                        return null;
                      }
                      return Validators.kRange(v);
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextFormField(
                    controller: _c,
                    focusNode: _cFocus,
                    enabled: _cEnabled,
                    decoration: const InputDecoration(
                      labelText: 'c (potencia, 0..1)',
                      helperText: 'Opcional — rango: 0.01..1',
                    ),
                    validator: (v) {
                      // optional: if empty OK; if provided validate range
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.cRange(v);
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
                if (showPercent) ...[
                  TextFormField(
                    controller: _kPercent,
                    focusNode: _kPercentFocus,
                    enabled: _kPercentEnabled,
                    decoration: const InputDecoration(
                      labelText: 'k% (eficiencia) *',
                      helperText: 'Rango: 0.01 .. 99.9999%',
                      suffixText: '%',
                    ),
                    validator: (v) {
                      final x = _toDoubleOrNull(v ?? '');
                      if (x == null) return 'k% es obligatorio';
                      if (x <= 0.01 || x > 99.9999) return 'k% debe ser (0.01, 99.9999]';
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextFormField(
                    controller: _cPercent,
                    focusNode: _cPercentFocus,
                    enabled: _cPercentEnabled,
                    decoration: const InputDecoration(
                      labelText: 'c% (potencia) *',
                      helperText: 'Rango: 0.01 .. 100%',
                      suffixText: '%',
                    ),
                    validator: (v) {
                      final x = _toDoubleOrNull(v ?? '');
                      if (x == null) return 'c% es obligatorio';
                      if (x <= 0.01 || x > 100) return 'c% debe ser (0.01, 100]';
                      return null;
                    },
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
                // Ocultar visualmente P mínima en la pantalla de porcentajes
                Visibility(
                  visible: !showPercent,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: TextFormField(
                    controller: _pMinW,
                    focusNode: _pMinWFocus,
                    decoration: const InputDecoration(
                      labelText: 'P mínima (W)',
                      helperText: 'Opcional — ≥ 0 W',
                    ),
                    validator: Validators.nonNegative,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    Expanded(
                      flex: 6,
                      child: ChartPanel(result: _result, loading: _loading),
                    ),
                  ],
                )
              else ...[
                form,
                const SizedBox(height: 12),
                ChartPanel(result: _result, loading: _loading),
              ],
              const SizedBox(height: 16),
              
              // ✅ BANNER con la inecuación
              if (_result != null) ...[
                InequalityBanner(
                  k: _getKNullable(),
                  c: _getCNullable(),
                  rlMin: _result!.rlMin,
                  rlMax: _result!.rlMax,
                  feasible: _result!.feasible,
                ),
                const SizedBox(height: 16),
              ],
              
              // Resultados
              RangesPanel(result: _rangesAsync),
              const SizedBox(height: 12),
              if (_result != null)
                Center(
                  child: ElevatedButton(
                    onPressed: () => context.push('/thanks'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text('Terminar'),
                    ),
                  ),
                ),
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
              // Sticky help drawer removed (no help card '¿Para qué me sirve?')
            ],
          );
        },
      ),
    );
  }
}
