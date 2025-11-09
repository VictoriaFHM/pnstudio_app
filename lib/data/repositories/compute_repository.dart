// lib/data/repositories/compute_repository.dart
import 'package:dio/dio.dart';
import '../models/compute_request.dart';
import '../models/compute_response.dart';
import '../network/http_client.dart';
import '../../core/constants/api_endpoints.dart';

class ComputeRepository {
  final Dio _dio;
  ComputeRepository({Dio? dio}) : _dio = dio ?? createHttpClient();

  Future<ComputeResponse> compute(ComputeRequest req) async {
    final res = await _dio.post(ApiEndpoints.compute, data: req.toJson());
    return ComputeResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // útil para debug o ejemplo en el form
  Future<ComputeResponse> example({
    double vth = 5,
    double rth = 1000,
    double k = 0.6,
    double? kPercent,
    double c = 0.85,
    double? cPercent,
    double? pMinW,
  }) async {
    final query = {
      'vth': vth,
      'rth': rth,
      'k': k,
      if (kPercent != null) 'kPercent': kPercent,
      'c': c,
      if (cPercent != null) 'cPercent': cPercent,
      if (pMinW != null) 'pMinW': pMinW,
    };
    final res = await _dio.get(
      ApiEndpoints.computeExample,
      queryParameters: query,
    );
    return ComputeResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
