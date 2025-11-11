// lib/core/utils/validators.dart

/// Top-level helper as requested: parses a string to double or returns null for empty input.
double? parseOrNull(String? s) =>
  (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim().replaceAll(',', '.'));

class Validators {
  /// Parses a nullable string to double or returns null for empty input.
  /// Normalizes comma decimals to dot.
  static double? parseOrNull(String? s) =>
      (s == null || s.trim().isEmpty) ? null : double.tryParse(s.trim().replaceAll(',', '.'));

  static String? requiredPositive(String? v, {double min = 1e-9}) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return 'Número inválido';
    if (x < min) return 'Debe ser ≥ $min';
    return null;
  }

  static String? nonNegative(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return 'Número inválido';
    if (x < 0) return 'Debe ser ≥ 0';
    return null;
  }

  // k en [1e-9, 0.999999]
  static String? kRange(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return 'Número inválido';
    if (x < 1e-9 || x > 0.999999) return 'k fuera de rango';
    return null;
  }

  // k% range hint for UI: 0.01 .. 99.9999 (in compute requests we accept 0.01 minimum)
  static String? kPercentRange(String? v, {bool forSave = false}) {
    if (v == null || v.trim().isEmpty) return null;
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return 'Número inválido';
    final min = forSave ? 1.0 : 0.01;
    final max = forSave ? 100.0 : 99.9999;
    if (x < min || x > max) return 'k% fuera de rango';
    return null;
  }

  // c en (0,1]
  static String? cRange(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return 'Número inválido';
    if (x < 1e-9 || x > 1.0) return 'c fuera de rango';
    return null;
  }

  // c% en (0,100]
  // c% range hint for UI: 0.01 .. 100
  static String? cPercentRange(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final x = double.tryParse(v.replaceAll(',', '.'));
    if (x == null) return 'Número inválido';
    if (x < 0.01 || x > 100.0) return 'c% fuera de rango';
    return null;
  }

  // regla: usar k o k%, y c o c%, pero no ambos a la vez
  static String? mutuallyExclusive(
    String? a,
    String? b,
    String labelA,
    String labelB,
  ) {
    final hasA = a != null && a.trim().isNotEmpty;
    final hasB = b != null && b.trim().isNotEmpty;
    if (hasA && hasB) return 'Usa $labelA o $labelB, no ambos';
    return null;
  }
}
