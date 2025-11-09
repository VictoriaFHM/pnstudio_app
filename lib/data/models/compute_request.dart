import 'package:json_annotation/json_annotation.dart';
part 'compute_request.g.dart';

@JsonSerializable()
class ComputeRequest {
  final double vth;
  final double rth;
  final double? k;
  final double? kPercent;
  final double? c;
  final double? cPercent;
  final double? pMinW;

  ComputeRequest({
    required this.vth,
    required this.rth,
    this.k,
    this.kPercent,
    this.c,
    this.cPercent,
    this.pMinW,
  });

  factory ComputeRequest.fromJson(Map<String, dynamic> json) =>
      _$ComputeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ComputeRequestToJson(this);
}
