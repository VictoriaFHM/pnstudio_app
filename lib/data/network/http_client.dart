// lib/data/network/http_client.dart
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

Dio createHttpClient() {
  final options = BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
    // validateStatus: (code) => code != null && code >= 200 && code < 400,
  );
  final dio = Dio(options);
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
