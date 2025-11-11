import 'package:json_annotation/json_annotation.dart';

part 'compute_response.g.dart';

@JsonSerializable()
class ComputeResponse {
  final bool feasible;
  final double pmax;
  final double rlMin;
  final double rlMax;
  final double etaMin;
  final double etaMax;
  final double pMin;
  final double pMaxByK;
  final double? recommendedRl;
  final double? etaAtRec;
  final double? pAtRec;

  const ComputeResponse({
    this.feasible = true, // ✅ Valor por defecto si viene null
    required this.pmax,
    required this.rlMin,
    required this.rlMax,
    required this.etaMin,
    required this.etaMax,
    required this.pMin,
    required this.pMaxByK,
    this.recommendedRl,
    this.etaAtRec,
    this.pAtRec,
  });

  factory ComputeResponse.fromJson(Map<String, dynamic> json) =>
      _$ComputeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ComputeResponseToJson(this);
}
