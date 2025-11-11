// lib/core/constants/api_endpoints.dart
import '../../env/env.dart';

class ApiEndpoints {
  static String get baseUrl => Env.baseUrl;

  // Paths (no duplicate /api)
  static const String compute = '/api/Compute';
  static const String computeExample = '/api/Compute/example';
  static const String calculations = '/api/Calculations';
  static String calculationById(int id) => '/api/Calculations/$id';
  static const String health = '/healthz';
}
