// lib/services/api/interceptors.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_constants.dart';

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
    final bodyStr = response.data.toString();
    final preview = bodyStr.length > 300 ? bodyStr.substring(0, 300) + '...' : bodyStr;
    print('← RESPONSE [${response.statusCode}] ${response.requestOptions.path}: $preview');
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

  // Prevent infinite refresh loops
  bool _isRefreshing = false;
  static const String _refreshTokenPath = '/auth/refresh-token';

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip injecting access token if this request explicitly opts out
    // (e.g. the refresh-token call which uses its own Authorization header)
    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = await _storage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only attempt refresh on 401 and only once
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Retry the original request with the new token
          final newToken = await _storage.read(key: 'access_token');
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          final response = await dio.request<dynamic>(
            opts.path,
            options: Options(
              method: opts.method,
              headers: opts.headers,
            ),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          _isRefreshing = false;
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed – clear tokens so the app routes to login
        await _storage.deleteAll();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Use a CLEAN Dio instance without interceptors to avoid recursion
      // and to prevent the AuthInterceptor from overwriting the Authorization
      // header with the expired access token.
      final cleanDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl + ApiConstants.apiVersion,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          ...ApiConstants.defaultHeaders,
          'Authorization': 'Bearer $refreshToken',
        },
        contentType: 'application/json',
        responseType: ResponseType.json,
      ));

      final response = await cleanDio.post(_refreshTokenPath);

      final data = response.data is Map<String, dynamic>
          ? (response.data['data'] ?? response.data) as Map<String, dynamic>
          : <String, dynamic>{};

      final newAccessToken =
          (data['token'] ?? data['accessToken'] ?? data['access_token'])
              ?.toString();
      if (newAccessToken == null || newAccessToken.isEmpty) return false;

      await _storage.write(key: 'access_token', value: newAccessToken);

      // Also update refresh token if the server rotated it
      final newRefreshToken =
          (data['refreshToken'] ?? data['refresh_token'])?.toString();
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
      }

      return true;
    } catch (e) {
      print('[AuthInterceptor] Refresh token failed: $e');
      return false;
    }
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('Error: ${err.message}');
    super.onError(err, handler);
  }
}
