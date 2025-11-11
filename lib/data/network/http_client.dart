// lib/data/network/http_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_endpoints.dart';

Dio createHttpClient() {
  // En web, XMLHttpRequest tiene restricciones CORS.
  // Si estás en localhost:55676, probablemente el backend esté en otra URL.
  // Solución: usa http para desarrollo local si es posible.
  String baseUrl = ApiEndpoints.baseUrl;
  
  // DEBUG: si estás en web y localhost, usa http en lugar de https
  if (kIsWeb && baseUrl.contains('localhost')) {
    baseUrl = baseUrl.replaceFirst('https://', 'http://');
  }

  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      // Headers CORS
      'Accept': 'application/json',
      'Access-Control-Allow-Credentials': 'true',
    },
    validateStatus: (code) => code != null && code >= 200 && code < 500,
  );
  final dio = Dio(options);
  
  // Interceptor de debug
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    logPrint: (object) {
      print('🔵 [Dio] $object');
    },
  ));
  
  // Interceptor personalizado para capturar errores CORS
  dio.interceptors.add(_CorsErrorInterceptor());
  
  return dio;
}

/// Interceptor personalizado para capturar errores CORS
class _CorsErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ DioError detectado:');
    print('   Tipo: ${err.type}');
    print('   Mensaje: ${err.message}');
    print('   URL: ${err.requestOptions.uri}');
    print('   Status Code: ${err.response?.statusCode}');
    
    // Si es error de conexión en web, probablemente es CORS
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.unknown) {
      print('   💡 Posible causa: CORS bloqueado o backend no alcanzable');
      print('   💡 Verifica que el backend tiene CORS habilitado');
    }
    
    super.onError(err, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log de respuestas con status >= 400
    if (response.statusCode != null && response.statusCode! >= 400) {
      print('⚠️  Status ${response.statusCode}: ${response.requestOptions.uri}');
    }
    super.onResponse(response, handler);
  }
}
