// lib/data/repositories/compute_repository.dart
import 'package:dio/dio.dart';

import 'package:pnstudio_app/core/constants/api_endpoints.dart';
import 'package:pnstudio_app/data/models/compute_request.dart';
import 'package:pnstudio_app/data/models/compute_response.dart';

class ComputeRepository {
  final Dio _dio;

  ComputeRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'content-type': 'application/json'},
            ),
          );

  Future<ComputeResponse> compute(ComputeRequest req) async {
    final resp = await _dio.post(
      ApiEndpoints.compute,
      data: req.toJson(), // Asegúrate de tener toJson en tu modelo
    );

    // La API devuelve JSON con los campos de ComputeResponse
    return ComputeResponse.fromJson(resp.data as Map<String, dynamic>);
  }
}
