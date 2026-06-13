// lib/services/api/interceptors.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('→ REQUEST: ${options.method} ${options.path}');
    print('→ HEADERS: ${options.headers}');
    if (options.data != null) print('→ BODY: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('← RESPONSE: ${response.statusCode}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('✗ ERROR: ${err.error}');
    super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final _storage = const FlutterSecureStorage();
  
  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 - token expired
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic in Phase 2
    }
    super.onError(err, handler);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('Error: ${err.message}');
    super.onError(err, handler);
  }
}
