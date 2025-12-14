import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncValue;
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

import '../../../core/utils/validators.dart';
// utils moved parsing into local helpers

import '../../mode_select/models/input_mode.dart';
import '../../../data/repositories/compute_repository.dart';
import '../../../data/models/compute_request.dart';
import '../../../data/models/compute_response.dart';

import '../widgets/chart_panel.dart';
import '../widgets/ranges_panel.dart';
import '../widgets/inequality_banner.dart';
// SectionHeader not used here because header is in the AppBar

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

  // Fireworks overlay controller
  Timer? _finishTimer;
  Timer? _fadeTimer;
  bool _showFinishOverlay = false;
  double _overlayOpacity = 1.0;

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
    _finishTimer?.cancel();
    _fadeTimer?.cancel();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Completa eficiencia (%) y potencia (%)'),
            ),
          );
          setState(() => _loading = false);
          return;
        }

        // Build request with ONLY the required fields for porcentaje mode
        final req = ComputeRequest(
          vth: vth,
          rth: rth,
          kPercent: kPctNullable,
          cPercent: cPctNullable,
        );
        final res = await _computeRepo.compute(req);
        setState(() => _result = res);
      } else if (widget.mode == InputMode.exacto) {
        // exact mode: parse k and c as exact values; require one of them? we rely on existing validators
        final kVal = _toDoubleOrNull(_k.text);
        final cVal = _toDoubleOrNull(_c.text);
        final pMin = _toDoubleOrNull(_pMinW.text);

        // If both c and pMin missing, backend requires at least one; enforce here
        if (cVal == null && pMin == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes ingresar c o P mínima (W)')),
          );
          setState(() => _loading = false);
          return;
        }

        final req = ComputeRequest(
          vth: vth,
          rth: rth,
          k: kVal,
          c: cVal,
          pMinW: pMin,
        );
        final res = await _computeRepo.compute(req);
        setState(() => _result = res);
      } else {
        // basico
        final pMin = _toDoubleOrNull(_pMinW.text);
        if (pMin == null) {
          // backend requires c/cPercent or pMinW; here ask user to provide pMinW
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes ingresar c% o P mínima (W)')),
          );
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

  // Show fireworks overlay for ~2.5s then fade and navigate to home ('/') clearing stack.
  void _onFinishPressed() {
    if (_showFinishOverlay) return;
    // display overlay
    setState(() {
      _showFinishOverlay = true;
      _overlayOpacity = 1.0;
    });

    // Cancel any existing timers
    _finishTimer?.cancel();
    _fadeTimer?.cancel();

    // After ~2.5s start fade-out
    _finishTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _overlayOpacity = 0.0);

      // After fade completes, navigate home clearing stack
      _fadeTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        try {
          context.go('/');
        } catch (_) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
        }
      });
    });
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
        // explicit back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Center the title in the AppBar and remove the subtitle + divider per UI request
        titleSpacing: 0,
        centerTitle: true,
        toolbarHeight: 84,
        title: Text(
          'Evaluación de Potencia Entregada a la Carga',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;
          final isMobile = c.maxWidth < 768;

          final form = Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _vth,
                  focusNode: _vthFocus,
                  decoration: const InputDecoration(
                    labelText: 'Vth (V) *',
                    helperText: 'Ingrese un valor mayor que cero.',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Ingrese un valor mayor que cero.';
                    final x = double.tryParse(v.replaceAll(',', '.'));
                    if (x == null) return 'Número inválido';
                    if (x <= 0) return 'Ingrese un valor mayor que cero.';
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rth,
                  focusNode: _rthFocus,
                  decoration: const InputDecoration(
                    labelText: 'Rth (Ω) *',
                    helperText: 'Ingrese un valor mayor que cero.',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Ingrese un valor mayor que cero.';
                    final x = double.tryParse(v.replaceAll(',', '.'));
                    if (x == null) return 'Número inválido';
                    if (x <= 0) return 'Ingrese un valor mayor que cero.';
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 8),
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
                      helperText: 'Rango: 0.01 % – 99.99 %',
                      suffixText: '%',
                    ),
                    validator: (v) {
                      final x = _toDoubleOrNull(v ?? '');
                      if (x == null) return 'k% es obligatorio';
                      if (x <= 0.01 || x > 99.9999)
                        return 'k% debe ser (0.01, 99.9999]';
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
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
                      helperText: 'Rango: 0.01 % – 100 %',
                      suffixText: '%',
                    ),
                    validator: (v) {
                      final x = _toDoubleOrNull(v ?? '');
                      if (x == null) return 'c% es obligatorio';
                      if (x <= 0.01 || x > 100)
                        return 'c% debe ser (0.01, 100]';
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
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
                // Botón Calcular con estilo olive y radio más grande
                ElevatedButton(
                  onPressed: _loading ? null : _onSubmit,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      const base = Color(0xFF6E8C1A);
                      const hover = Color(0xFF88A71D);
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.pressed))
                        return hover;
                      return base;
                    }),
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Colors.white,
                    ),
                    elevation: WidgetStateProperty.resolveWith<double>(
                      (states) => states.contains(WidgetState.pressed) ? 6 : 4,
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Calcular',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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
              // Header moved into AppBar; keep a small top spacer
              SizedBox(height: isMobile ? 12 : 16),
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
              const SizedBox(height: 8),

              // ✅ BANNER con la inecuación (solo si es factible)
              if (_result != null && _result!.feasible) ...[
                InequalityBanner(
                  k: _getKNullable(),
                  c: _getCNullable(),
                  rlMin: _result!.rlMin,
                  rlMax: _result!.rlMax,
                  feasible: _result!.feasible,
                ),
                const SizedBox(height: 8),
              ],

              // Resultados
              RangesPanel(result: _rangesAsync),
              const SizedBox(height: 8),
              if (_result != null)
                Center(
                  child: ElevatedButton(
                    onPressed: _onFinishPressed,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        const base = Color(0xFF6E8C1A); // Olive green (unified)
                        const hover = Color(
                          0xFF5A7315,
                        ); // darker olive for hover
                        if (states.contains(WidgetState.hovered)) {
                          return hover;
                        }
                        return base;
                      }),
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.white,
                      ),
                      elevation: WidgetStateProperty.resolveWith<double>((
                        states,
                      ) {
                        if (states.contains(WidgetState.hovered)) {
                          return 8;
                        }
                        return 4;
                      }),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Text(
                        'Terminar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: mainColumn,
                  ),
                ),
              ),
              // Fireworks overlay with fade-out animation
              if (_showFinishOverlay)
                AnimatedOpacity(
                  opacity: _overlayOpacity,
                  duration: const Duration(milliseconds: 300),
                  child: AbsorbPointer(
                    absorbing: _overlayOpacity > 0.1,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      child: const Center(child: _FireworksParticles()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Simple fireworks particle animation widget (no Lottie dependency)
class _FireworksParticles extends StatefulWidget {
  const _FireworksParticles();

  @override
  State<_FireworksParticles> createState() => _FireworksParticlesState();
}

class _FireworksParticlesState extends State<_FireworksParticles>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FireworksPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final List<Particle> particles = [];
  late Random _rng;

  _FireworksPainter(this.progress) {
    _rng = Random();
    _generateParticles();
  }

  void _generateParticles() {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFFE66D), // Yellow
      const Color(0xFF95E1D3), // Mint
      const Color(0xFFF38181), // Pink
      const Color(0xFFAA96DA), // Purple
      const Color(0xFFFCBB25), // Bright Yellow
    ];

    // Generate 250+ particles for REAL fireworks effect
    for (int i = 0; i < 250; i++) {
      final angle = (_rng.nextDouble() * 2 * pi);
      final speed = 150 + _rng.nextDouble() * 400; // Faster particles
      final size = 2 + _rng.nextDouble() * 10;

      particles.add(
        Particle(
          baseX: 683 / 2, // Center X
          baseY: 384 / 2, // Center Y
          vx: (speed * cos(angle)),
          vy: (speed * sin(angle)),
          color: colors[_rng.nextInt(colors.length)],
          size: size,
          trailLength: 5 + _rng.nextInt(15),
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background fade (semi-transparent black overlay)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.1 * progress),
    );

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final particle in particles) {
      // Physics: position = v * t + 0.5 * g * t²
      final t = progress;
      final x = centerX + particle.vx * t * 60 - particle.vx * t * t * 20;
      final y = centerY + particle.vy * t * 60 + 150 * t * t; // Gravity effect

      // Alpha fade (particles disappear as progress approaches 1)
      final alpha = (1.0 - progress).clamp(0.0, 1.0);

      // Size shrink over time
      final currentSize = particle.size * (1 - progress * 0.7);

      // Draw particle with glow effect
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: alpha * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final particlePaint = Paint()
        ..color = particle.color.withValues(alpha: alpha)
        ..isAntiAlias = true;

      // Glow
      canvas.drawCircle(Offset(x, y), currentSize * 2, glowPaint);
      // Particle
      canvas.drawCircle(Offset(x, y), currentSize, particlePaint);

      // Draw trailing sparkles
      if (progress > 0.1) {
        for (int i = 1; i < particle.trailLength; i++) {
          final trailProgress = progress - (i * 0.02);
          if (trailProgress > 0) {
            final trailX =
                centerX +
                particle.vx * trailProgress * 60 -
                particle.vx * trailProgress * trailProgress * 20;
            final trailY =
                centerY +
                particle.vy * trailProgress * 60 +
                150 * trailProgress * trailProgress;

            final trailAlpha =
                (1.0 - trailProgress).clamp(0.0, 1.0) * 0.3; // Trail is dimmer
            final trailSize = particle.size * 0.5 * (1 - trailProgress * 0.7);

            final trailPaint = Paint()
              ..color = particle.color.withValues(alpha: trailAlpha)
              ..isAntiAlias = true;

            canvas.drawCircle(Offset(trailX, trailY), trailSize, trailPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_FireworksPainter oldDelegate) => true;
}

class Particle {
  final double baseX, baseY;
  final double vx, vy;
  final Color color;
  final double size;
  final int trailLength;

  Particle({
    required this.baseX,
    required this.baseY,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.trailLength,
  });
}
