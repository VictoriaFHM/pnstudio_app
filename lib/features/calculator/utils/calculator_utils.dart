/// Utilidades de parsing y validación null-safe para la calculadora
library;

/// Verifica si una cadena está vacía (null o whitespace)
bool isEmpty(String? s) => s == null || s.trim().isEmpty;

/// Convierte un TextEditingController a double o null (null-safe)
double? toDoubleOrNull(String? text) {
  // Use shared validator helper if available to normalize parsing
  try {
    // Importing Validators here would create a cycle in some setups; prefer local parse
    if (isEmpty(text)) return null;
    return double.tryParse(text!.trim().replaceAll(',', '.'));
  } catch (_) {
    return null;
  }
}

/// Valida que k esté en rango (0, 1)
String? validateKExacto(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  final x = toDoubleOrNull(v);
  if (x == null) return 'Número inválido';
  if (x <= 0 || x > 1) return 'k debe estar entre 0 y 1 (exclusivo en 0)';
  return null;
}

/// Valida que k% esté en rango (0, 100)
String? validateKPorcentaje(String? v) {
  if (v == null || v.trim().isEmpty) return null;
  final x = toDoubleOrNull(v);
  if (x == null) return 'Número inválido';
  if (x < 0.01 || x > 99.9999) return 'k% debe estar entre 0.01 y 99.9999';
  return null;
}

/// Valida que c esté en rango (0, 1]
String? validateCExacto(String? v) {
  if (v == null || v.trim().isEmpty) return null; // c es opcional
  final x = toDoubleOrNull(v);
  if (x == null) return 'Número inválido';
  if (x <= 0 || x > 1) return 'c debe estar entre 0 y 1 (exclusivo en 0)';
  return null;
}

/// Valida que c% esté en rango (0, 100]
String? validateCPorcentaje(String? v) {
  if (v == null || v.trim().isEmpty) return null; // c% es opcional
  final x = toDoubleOrNull(v);
  if (x == null) return 'Número inválido';
  if (x < 0.01 || x > 100.0) return 'c% debe estar entre 0.01 y 100';
  return null;
}

/// Valida que pMinW esté en rango [0, ∞)
String? validatePMinW(String? v) {
  if (v == null || v.trim().isEmpty) return null; // pMinW es opcional
  final x = toDoubleOrNull(v);
  if (x == null) return 'Número inválido';
  if (x < 0) return 'pMinW debe ser ≥ 0';
  return null;
}

/// Valida que k/k% sean mutualmente excluyentes pero uno obligatorio
String? validateKOneOf(String? kVal, String? kPercentVal) {
  final kEmpty = isEmpty(kVal);
  final kPercentEmpty = isEmpty(kPercentVal);

  if (kEmpty && kPercentEmpty) {
    return 'Debes ingresar k o k% (uno obligatorio)';
  }
  if (!kEmpty && !kPercentEmpty) {
    return 'No puedes ingresar k y k% a la vez';
  }
  return null;
}

/// Valida que c/c% sean mutualmente excluyentes (ambos opcionales)
String? validateCOneOf(String? cVal, String? cPercentVal) {
  final cEmpty = isEmpty(cVal);
  final cPercentEmpty = isEmpty(cPercentVal);

  if (!cEmpty && !cPercentEmpty) {
    return 'No puedes ingresar c y c% a la vez';
  }
  return null;
}
