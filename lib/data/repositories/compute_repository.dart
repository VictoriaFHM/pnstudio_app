// lib/data/repositories/compute_repository.dart
import 'package:dio/dio.dart';
import '../models/compute_request.dart';
import '../models/compute_response.dart';
import '../network/http_client.dart';
import '../network/mock_compute_repository.dart';
import '../../core/constants/api_endpoints.dart';

class ComputeRepository {
  final Dio _dio;
  final MockComputeRepository _mock = MockComputeRepository();
  
  /// 🔴 CAMBIAR AQUÍ ENTRE MOCK Y REAL
  /// true = usa API real (localhost:5230 o Azure)
  /// false = usa datos ficticios (para testear sin backend)
  static const bool useMockData = false; // 👈 CAMBIA AQUÍ

  ComputeRepository({Dio? dio}) : _dio = dio ?? createHttpClient();

  Future<ComputeResponse> compute(ComputeRequest req) async {
    if (useMockData) {
      // Usa datos ficticios para testing
      return await _mock.compute(req);
    }
    
    // Usa API real
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
    if (useMockData) {
      return await _mock.compute(
        ComputeRequest(
          vth: vth,
          rth: rth,
          k: k,
          kPercent: kPercent,
          c: c,
          cPercent: cPercent,
          pMinW: pMinW,
        ),
      );
    }
    
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
