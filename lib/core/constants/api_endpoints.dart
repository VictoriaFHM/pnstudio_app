// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5230',
  );

  // Paths
  static const String compute = '/api/Compute';
  static const String computeExample = '/api/Compute/example';
  static const String calculations = '/api/Calculations';
  static String calculationById(int id) => '/api/Calculations/$id';
  static const String health = '/healthz';
}
