import 'dart:math' as math;

/// Calcula el valor crítico de k según el modelo
/// kcrit = (1 + sqrt(max(0, 1 - c))) / 2
double calculateKcrit(double c) {
  return (1 + math.sqrt(math.max(0, 1 - c))) / 2.0;
}

/// Compara dos doubles con tolerancia numérica
bool isClose(double a, double b, [double eps = 1e-9]) {
  return (a - b).abs() < eps;
}

/// Formatea un número con 3 decimales
String formatNum(double value, {int decimals = 3}) {
  return value.toStringAsFixed(decimals);
}

/// Redondea hacia arriba al múltiplo más cercano de step
double roundUp(double x, double step) {
  return (x / step).ceil() * step;
}

/// Redondea hacia abajo al múltiplo más cercano de step
double roundDown(double x, double step) {
  return (x / step).floor() * step;
}
