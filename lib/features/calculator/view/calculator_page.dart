import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncValue;

import '../../../core/utils/validators.dart';
import '../utils/calculator_utils.dart';

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

  double? toDoubleOrNull(String? text) {
    if (isEmpty(text)) return null;
    return double.tryParse(text!.trim().replaceAll(',', '.'));
  }

  /// Obtiene el valor actual de k según el modo (nullable)
  double? _getKNullable() {
    if (widget.mode == InputMode.exacto) {
      return toDoubleOrNull(_k.text);
    }
    if (widget.mode == InputMode.porcentaje) {
      final kPct = toDoubleOrNull(_kPercent.text);
      return kPct == null ? null : (kPct / 100.0);
    }
    return null;
  }

  /// Obtiene el valor actual de c según el modo (nullable)
  double? _getCNullable() {
    if (widget.mode == InputMode.exacto) {
      return toDoubleOrNull(_c.text);
    }
    if (widget.mode == InputMode.porcentaje) {
      final cPct = toDoubleOrNull(_cPercent.text);
      return cPct == null ? null : (cPct / 100.0);
    }
    return null;
  }

  ComputeRequest _buildRequest() {
    final vth = double.parse(_vth.text.replaceAll(',', '.'));
    final rth = double.parse(_rth.text.replaceAll(',', '.'));
    
    // Parse optionals to null if empty using null-safe helpers
    final double? k = toDoubleOrNull(_k.text);
    final double? kPercent = toDoubleOrNull(_kPercent.text);
    final double? c = toDoubleOrNull(_c.text);
    final double? cPercent = toDoubleOrNull(_cPercent.text);
    final double? pMinW = toDoubleOrNull(_pMinW.text);

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
      // Validar que k/k% sean mutualmente excluyentes pero uno obligatorio
      final kError = validateKOneOf(_k.text, _kPercent.text);
      if (kError != null) {
        setState(() {
          _loading = false;
          _error = kError;
        });
        return;
      }

      // Validar que c/c% sean mutualmente excluyentes (ambos opcionales)
      final cError = validateCOneOf(_c.text, _cPercent.text);
      if (cError != null) {
        setState(() {
          _loading = false;
          _error = cError;
        });
        return;
      }

      // Validar el formulario (Vth, Rth, rangos de k, c, pMinW)
      if (!_formKey.currentState!.validate()) {
        _focusFirstInvalid();
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

  void _focusFirstInvalid() {
    // Check Vth
    if (_vth.text.trim().isEmpty || double.tryParse(_vth.text.replaceAll(',', '.')) == null) {
      FocusScope.of(context).requestFocus(_vthFocus);
      return;
    }
    // Check Rth
    if (_rth.text.trim().isEmpty || double.tryParse(_rth.text.replaceAll(',', '.')) == null) {
      FocusScope.of(context).requestFocus(_rthFocus);
      return;
    }

    // Check k / k% one-of requirement depending on mode
    if (widget.mode == InputMode.exacto) {
      final hasK = _k.text.trim().isNotEmpty;
      final hasKp = _kPercent.text.trim().isNotEmpty;
      if (!hasK && !hasKp) {
        FocusScope.of(context).requestFocus(_kFocus);
        return;
      }
      if (hasK) {
        final ok = double.tryParse(_k.text.replaceAll(',', '.')) != null;
        if (!ok) {
          FocusScope.of(context).requestFocus(_kFocus);
          return;
        }
      }
    } else if (widget.mode == InputMode.porcentaje) {
      final hasK = _k.text.trim().isNotEmpty;
      final hasKp = _kPercent.text.trim().isNotEmpty;
      if (!hasK && !hasKp) {
        FocusScope.of(context).requestFocus(_kPercentFocus);
        return;
      }
      if (hasKp) {
        final ok = double.tryParse(_kPercent.text.replaceAll(',', '.')) != null;
        if (!ok) {
          FocusScope.of(context).requestFocus(_kPercentFocus);
          return;
        }
      }
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
                    helperText: 'Obligatorio',
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
                    helperText: 'Obligatorio',
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
                      labelText: 'k% (eficiencia, 0..100)',
                    ),
                    validator: (v) {
                      final otherHas = _k.text.trim().isNotEmpty;
                      if (v == null || v.trim().isEmpty) {
                        if (!otherHas) return 'Campo obligatorio';
                        return null;
                      }
                      return Validators.kPercentRange(v);
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  TextFormField(
                    controller: _cPercent,
                    focusNode: _cPercentFocus,
                    enabled: _cPercentEnabled,
                    decoration: const InputDecoration(
                      labelText: 'c% (potencia, 0..100)',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.cPercentRange(v);
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
                TextFormField(
                  controller: _pMinW,
                  focusNode: _pMinWFocus,
                  decoration: const InputDecoration(
                    labelText: 'P mínima (W)',
                  ),
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
