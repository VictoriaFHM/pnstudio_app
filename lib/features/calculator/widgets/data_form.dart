import 'package:flutter/material.dart';
import 'package:pnstudio_app/core/constants/spacing.dart';
import 'package:pnstudio_app/core/widgets/section_title.dart';
import 'package:pnstudio_app/features/mode_select/models/input_mode.dart';

typedef SubmitFn =
    void Function(
      double vth,
      double rth, {
      double? k,
      double? kPercent,
      double? c,
      double? cPercent,
      double? pMinW,
    });

class DataForm extends StatefulWidget {
  final InputMode mode;
  final SubmitFn onSubmit;
  final bool busy;
  const DataForm({
    super.key,
    required this.mode,
    required this.onSubmit,
    this.busy = false,
  });

  // Para móvil — placeholder mínimo cuando aún no armamos todas las entradas
  const DataForm.mobilePlaceholder({super.key})
    : mode = InputMode.basico,
      onSubmit = _noop,
      busy = false;

  static void _noop(
    double vth,
    double rth, {
    double? k,
    double? kPercent,
    double? c,
    double? cPercent,
    double? pMinW,
  }) {}

  @override
  State<DataForm> createState() => _DataFormState();
}

class _DataFormState extends State<DataForm> {
  final _formKey = GlobalKey<FormState>();
  final _vth = TextEditingController();
  final _rth = TextEditingController();
  final _k = TextEditingController();
  final _kPct = TextEditingController();
  final _c = TextEditingController();
  final _cPct = TextEditingController();
  final _pMin = TextEditingController();

  @override
  void dispose() {
    _vth.dispose();
    _rth.dispose();
    _k.dispose();
    _kPct.dispose();
    _c.dispose();
    _cPct.dispose();
    _pMin.dispose();
    super.dispose();
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requerido' : null;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(text: 'Datos'),
              const SizedBox(height: Gaps.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vth,
                      decoration: const InputDecoration(labelText: 'Vth [V]'),
                      keyboardType: TextInputType.number,
                      validator: _req,
                    ),
                  ),
                  const SizedBox(width: Gaps.md),
                  Expanded(
                    child: TextFormField(
                      controller: _rth,
                      decoration: const InputDecoration(labelText: 'Rth [Ω]'),
                      keyboardType: TextInputType.number,
                      validator: _req,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gaps.md),
              // campos según modo
              if (widget.mode == InputMode.exacto) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _k,
                        decoration: const InputDecoration(labelText: 'k'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: Gaps.md),
                    Expanded(
                      child: TextFormField(
                        controller: _c,
                        decoration: const InputDecoration(labelText: 'c'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ] else if (widget.mode == InputMode.porcentaje) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _kPct,
                        decoration: const InputDecoration(labelText: 'k [%]'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: Gaps.md),
                    Expanded(
                      child: TextFormField(
                        controller: _cPct,
                        decoration: const InputDecoration(labelText: 'c [%]'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: Gaps.md),
              TextFormField(
                controller: _pMin,
                decoration: const InputDecoration(
                  labelText: 'Potencia mínima Pmin [W] (opcional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: Gaps.lg),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: widget.busy
                      ? null
                      : () {
                          if (!(_formKey.currentState?.validate() ?? false))
                            return;
                          final vth = double.parse(_vth.text);
                          final rth = double.parse(_rth.text);
                          final k = _k.text.isEmpty
                              ? null
                              : double.parse(_k.text);
                          final c = _c.text.isEmpty
                              ? null
                              : double.parse(_c.text);
                          final kPct = _kPct.text.isEmpty
                              ? null
                              : double.parse(_kPct.text);
                          final cPct = _cPct.text.isEmpty
                              ? null
                              : double.parse(_cPct.text);
                          final pMin = _pMin.text.isEmpty
                              ? null
                              : double.parse(_pMin.text);
                          widget.onSubmit(
                            vth,
                            rth,
                            k: k,
                            c: c,
                            kPercent: kPct,
                            cPercent: cPct,
                            pMinW: pMin,
                          );
                        },
                  child: Text(widget.busy ? 'Calculando…' : 'Calcular'),
                ),
              ),
              const SizedBox(height: Gaps.sm),
              Text(
                'Tip: puedes dejar k/c en blanco si usas porcentajes, o viceversa.',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
