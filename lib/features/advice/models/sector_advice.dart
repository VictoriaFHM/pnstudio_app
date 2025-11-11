class SectorAdvice {
  final String sector;
  final String causasTecnicas;
  final double? eficiencia;
  final double? potencia;
  final String? imageAsset;

  SectorAdvice({
    required this.sector,
    required this.causasTecnicas,
    this.eficiencia,
    this.potencia,
    this.imageAsset,
  });

  factory SectorAdvice.fromJson(Map<String, dynamic> json) {
    return SectorAdvice(
      sector: json['sector'] as String? ?? '',
      causasTecnicas: json['causasTecnicas'] as String? ?? '',
      eficiencia: json['eficiencia'] == null ? null : (json['eficiencia'] as num).toDouble(),
      potencia: json['potencia'] == null ? null : (json['potencia'] as num).toDouble(),
      imageAsset: json['imageAsset'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'sector': sector,
        'causasTecnicas': causasTecnicas,
        'eficiencia': eficiencia,
        'potencia': potencia,
        'imageAsset': imageAsset,
      };
}
