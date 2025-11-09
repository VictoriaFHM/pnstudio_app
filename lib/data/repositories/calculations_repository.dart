// lib/data/repositories/calculations_repository.dart
import 'package:dio/dio.dart';
import '../models/calculation_dto.dart';
import '../models/compute_request.dart';
import '../network/http_client.dart';
import '../../core/constants/api_endpoints.dart';

class CalculationsRepository {
  final Dio _dio;
  CalculationsRepository({Dio? dio}) : _dio = dio ?? createHttpClient();

  Future<List<CalculationDto>> getCalculations({int take = 20}) async {
    final res = await _dio.get(
      ApiEndpoints.calculations,
      queryParameters: {'take': take},
    );
    final data = res.data as List<dynamic>;
    return data
        .map((e) => CalculationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CalculationDto> getById(int id) async {
    final res = await _dio.get(ApiEndpoints.calculationById(id));
    return CalculationDto.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CalculationDto> save(ComputeRequest req, {int? projectId}) async {
    final body = {
      ...req.toJson(),
      if (projectId != null) 'projectId': projectId,
    };
    final res = await _dio.post(ApiEndpoints.calculations, data: body);
    return CalculationDto.fromJson(res.data as Map<String, dynamic>);
  }
}
