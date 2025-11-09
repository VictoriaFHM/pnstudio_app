// lib/features/mode_select/models/input_mode.dart
enum InputMode {
  basico, // sólo vth, rth, (pMinW opcional)
  exacto, // k y c en [0..1]
  porcentaje, // k% y c% en [0..100]
}

extension InputModeX on InputMode {
  String get label {
    switch (this) {
      case InputMode.basico:
        return 'Básico';
      case InputMode.exacto:
        return 'Exacto';
      case InputMode.porcentaje:
        return 'Porcentaje';
    }
  }
}
