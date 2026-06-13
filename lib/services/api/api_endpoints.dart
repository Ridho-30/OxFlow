// lib/services/api/api_endpoints.dart

class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password'; // PATCH – used in profile
  
  // Users
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  
  // Categories
  static const String categories = '/categories';
  static String categoryDetail(String id) => '/categories/$id';
  
  // Transactions
  static const String transactions = '/transactions';
  static String transactionDetail(String id) => '/transactions/$id';
  
  // Budget
  static const String budget = '/budget';
  static const String budgetStatus = '/budget/status';
  
  // Laporan
  static const String laporanDaily = '/laporan/daily';
  static const String laporanWeekly = '/laporan/weekly';
  static const String laporanMonthly = '/laporan/monthly';
  static const String laporanExport = '/laporan/exportLaporan';
  
  // Analysis
  static const String analysisSpendingByCategory = '/analysis/spending-by-category';
  static const String analysisTrend = '/analysis/spending-trend';
  static const String analysisBudgetStatus = '/analysis/budget-status';
}
