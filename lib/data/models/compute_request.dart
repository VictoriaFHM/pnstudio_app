import 'package:json_annotation/json_annotation.dart';

part 'compute_request.g.dart';

@JsonSerializable()
class ComputeRequest {
  final double vth;
  final double rth;
  final double? k;
  @JsonKey(includeIfNull: false)
  final double? kPercent;
  final double? c;
  @JsonKey(includeIfNull: false)
  final double? cPercent;
  @JsonKey(includeIfNull: false)
  final double? pMinW;

  const ComputeRequest({
    required this.vth,
    required this.rth,
    this.k,
    this.kPercent,
    this.c,
    this.cPercent,
    this.pMinW,
  });

  // Si alguna vez necesitás parsear un request desde JSON
  factory ComputeRequest.fromJson(Map<String, dynamic> json) =>
      _$ComputeRequestFromJson(json);

  // Para enviar al backend
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> m = {
      'vth': vth,
      'rth': rth,
    };
    if (k != null) m['k'] = k;
    if (kPercent != null) m['kPercent'] = kPercent;
    if (c != null) m['c'] = c;
    if (cPercent != null) m['cPercent'] = cPercent;
    if (pMinW != null) m['pMinW'] = pMinW;
    return m;
  }
}
