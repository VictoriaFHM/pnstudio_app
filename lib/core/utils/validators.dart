class Validators {
  static String? requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    final d = double.tryParse(v);
    if (d == null) return 'Número inválido';
    return null;
  }

  static String? positive(String? v, {double min = 1e-9}) {
    final d = double.tryParse(v ?? '');
    if (d == null) return 'Número inválido';
    if (d < min) return 'Debe ser ≥ $min';
    return null;
  }

  static String? kOrC(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final d = double.tryParse(v);
    if (d == null) return 'Número inválido';
    if (d <= 1e-9 || d >= 1) return 'Rango: (0, 1)';
    return null;
  }

  static String? percent(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final d = double.tryParse(v);
    if (d == null) return 'Número inválido';
    if (d < 0.0001 || d > 100) return 'Rango: 0.0001–100';
    return null;
  }

  static String? nonNegative(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final d = double.tryParse(v);
    if (d == null) return 'Número inválido';
    if (d < 0) return 'Debe ser ≥ 0';
    return null;
  }
}
