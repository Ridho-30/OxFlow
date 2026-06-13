// lib/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://ox-flow-backend.vercel.app';
  static const String apiVersion = '/api';
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
