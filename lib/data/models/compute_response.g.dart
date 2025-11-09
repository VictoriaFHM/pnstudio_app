// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compute_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComputeResponse _$ComputeResponseFromJson(Map<String, dynamic> json) =>
    ComputeResponse(
      feasible: json['feasible'] as bool,
      pmax: (json['pmax'] as num).toDouble(),
      rlMin: (json['rlMin'] as num).toDouble(),
      rlMax: (json['rlMax'] as num).toDouble(),
      etaMin: (json['etaMin'] as num).toDouble(),
      etaMax: (json['etaMax'] as num).toDouble(),
      pMin: (json['pMin'] as num).toDouble(),
      pMaxByK: (json['pMaxByK'] as num).toDouble(),
      recommendedRl: (json['recommendedRl'] as num?)?.toDouble(),
      etaAtRec: (json['etaAtRec'] as num?)?.toDouble(),
      pAtRec: (json['pAtRec'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ComputeResponseToJson(ComputeResponse instance) =>
    <String, dynamic>{
      'feasible': instance.feasible,
      'pmax': instance.pmax,
      'rlMin': instance.rlMin,
      'rlMax': instance.rlMax,
      'etaMin': instance.etaMin,
      'etaMax': instance.etaMax,
      'pMin': instance.pMin,
      'pMaxByK': instance.pMaxByK,
      'recommendedRl': instance.recommendedRl,
      'etaAtRec': instance.etaAtRec,
      'pAtRec': instance.pAtRec,
    };
