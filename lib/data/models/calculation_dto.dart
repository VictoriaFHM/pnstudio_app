// lib/data/models/calculation_dto.dart
class CalculationDto {
  final int id;
  final double vth;
  final double rth;
  final double k;
  final double c;
  final double pmax;
  final double rlMin;
  final double rlMax;
  final double? recommendedRl;
  final double? etaAtRec;
  final double? pAtRec;
  final double pMin;
  final double pMaxByK;
  final String? regime;
  final DateTime createdAtUtc;

  const CalculationDto({
    required this.id,
    required this.vth,
    required this.rth,
    required this.k,
    required this.c,
    required this.pmax,
    required this.rlMin,
    required this.rlMax,
    this.recommendedRl,
    this.etaAtRec,
    this.pAtRec,
    required this.pMin,
    required this.pMaxByK,
    this.regime,
    required this.createdAtUtc,
  });

  factory CalculationDto.fromJson(Map<String, dynamic> json) {
    return CalculationDto(
      id: (json['id'] as num).toInt(),
      vth: (json['vth'] as num).toDouble(),
      rth: (json['rth'] as num).toDouble(),
      k: (json['k'] as num).toDouble(),
      c: (json['c'] as num).toDouble(),
      pmax: (json['pmax'] as num).toDouble(),
      rlMin: (json['rlMin'] as num).toDouble(),
      rlMax: (json['rlMax'] as num).toDouble(),
      recommendedRl: (json['recommendedRl'] as num?)?.toDouble(),
      etaAtRec: (json['etaAtRec'] as num?)?.toDouble(),
      pAtRec: (json['pAtRec'] as num?)?.toDouble(),
      pMin: (json['pMin'] as num).toDouble(),
      pMaxByK: (json['pMaxByK'] as num).toDouble(),
      regime: json['regime'] as String?,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vth': vth,
    'rth': rth,
    'k': k,
    'c': c,
    'pmax': pmax,
    'rlMin': rlMin,
    'rlMax': rlMax,
    'recommendedRl': recommendedRl,
    'etaAtRec': etaAtRec,
    'pAtRec': pAtRec,
    'pMin': pMin,
    'pMaxByK': pMaxByK,
    'regime': regime,
    'createdAtUtc': createdAtUtc.toIso8601String(),
  };
}
