enum InputMode { basico, exacto, porcentaje }

extension InputModeX on InputMode {
  String get label => switch (this) {
    InputMode.basico => 'Básico',
    InputMode.exacto => 'Valores exactos',
    InputMode.porcentaje => 'Porcentaje',
  };

  String get description => switch (this) {
    InputMode.basico => 'Solo Vth y RTh',
    InputMode.exacto => 'Vth, RTh, k y c',
    InputMode.porcentaje => 'Vth, RTh, k% y c%',
  };
}
