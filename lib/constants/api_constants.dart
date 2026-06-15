// lib/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://ox-flow-backend.vercel.app';
  static const String apiVersion = '/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60); // OCR/LLM calls can take ~30s
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Timeout khusus untuk endpoint /ocr/parse yang memanggil LLM Gemini
  static const Duration ocrReceiveTimeout = Duration(seconds: 90);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

