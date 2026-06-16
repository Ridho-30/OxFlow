// lib/services/api/api_endpoints.dart

class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // Users
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String deleteAccount = '/users/account';

  // Categories
  static const String categories = '/categories';
  static String categoryDetail(String id) => '/categories/$id';

  // Transactions
  static const String transactions = '/transactions';
  static String transactionDetail(String id) => '/transactions/$id';
  static const String uploadReceipt = '/transactions/upload-receipt';

  // Budget
  static const String budget = '/budget';
  static const String budgetStatus = '/budget/status';

  // Laporan
  static const String laporanDaily = '/laporan/daily';
  static const String laporanWeekly = '/laporan/weekly';
  static const String laporanMonthly = '/laporan/monthly';
  static const String laporanExport = '/laporan/export';
  static const String laporanHistory = '/laporan/history';

  // Analysis / Analytics
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String analyticsByCategory = '/analytics/by-category';
  static const String analyticsTrend = '/analytics/trend';

  // OCR — parse raw text via backend Gemini LLM
  static const String ocrParse = '/ocr/parse';
}

