// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compute_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComputeRequest _$ComputeRequestFromJson(Map<String, dynamic> json) =>
    ComputeRequest(
      vth: (json['vth'] as num).toDouble(),
      rth: (json['rth'] as num).toDouble(),
      k: (json['k'] as num?)?.toDouble(),
      kPercent: (json['kPercent'] as num?)?.toDouble(),
      c: (json['c'] as num?)?.toDouble(),
      cPercent: (json['cPercent'] as num?)?.toDouble(),
      pMinW: (json['pMinW'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ComputeRequestToJson(ComputeRequest instance) =>
    <String, dynamic>{
      'vth': instance.vth,
      'rth': instance.rth,
      'k': instance.k,
      'kPercent': instance.kPercent,
      'c': instance.c,
      'cPercent': instance.cPercent,
      'pMinW': instance.pMinW,
    };
