// lib/services/api/dio_config.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../constants/api_constants.dart';
import 'interceptors.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl + ApiConstants.apiVersion,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: ApiConstants.defaultHeaders,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }
    
    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}
