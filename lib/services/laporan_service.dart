// lib/services/laporan_service.dart

import 'package:flutter/foundation.dart';
import 'api/api_client.dart';
import 'api/api_endpoints.dart';
import '../models/transaction/transaction_model.dart';
import '../models/analytics/analytics_dashboard_model.dart';
import '../models/analytics/analytics_category_model.dart';
import '../models/analytics/analytics_trend_model.dart';

class LaporanService {
  final ApiClient _apiClient;

  LaporanService(this._apiClient);

  /// Helper to extract list from JSON response
  List<dynamic> _extractList(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) {
      for (final key in ['data', 'transactions', 'reports', 'items', 'result', 'results']) {
        if (value[key] != null) {
          final found = _extractList(value[key]);
          if (found.isNotEmpty) return found;
        }
      }
    }
    return [];
  }

  /// GET /api/transactions — Fetch transactions within date range
  Future<List<TransactionModel>> getTransactions({
    required String startDate,
    required String endDate,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.transactions,
        queryParameters: {
          'page': page,
          'limit': limit,
          'start_date': startDate,
          'end_date': endDate,
          'sort': 'date_desc',
        },
      );

      if (kDebugMode) {
        debugPrint('[LaporanService] Raw transactions response: $response');
      }

      final dynamic rawData = response['data'] ?? response;
      final List<dynamic> list = _extractList(rawData);

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => TransactionModel.fromJsonWithCategories(item, {}))
          .toList();
    } catch (e) {
      debugPrint('[LaporanService] getTransactions error: $e');
      rethrow;
    }
  }

  /// GET /api/transactions/{id} — Fetch transaction detail with item breakdown
  Future<TransactionModel> getTransactionDetail(String transactionId) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.transactionDetail(transactionId),
      );

      if (kDebugMode) {
        debugPrint('[LaporanService] Raw transaction detail response: $response');
      }

      final data = response['data'] ?? response;
      return TransactionModel.fromJsonWithCategories(data as Map<String, dynamic>, {});
    } catch (e) {
      debugPrint('[LaporanService] getTransactionDetail error: $e');
      rethrow;
    }
  }

  /// GET /api/analytics/dashboard — Fetch analytics summary (income, expense, balance, avg daily)
  Future<AnalyticsDashboardModel> getAnalyticsDashboard({
    int? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (month != null) params['month'] = month;
      if (year != null) params['year'] = year;

      final response = await _apiClient.get(
        ApiEndpoints.analyticsDashboard,
        queryParameters: params,
      );

      if (kDebugMode) {
        debugPrint('[LaporanService] Raw analytics dashboard response: $response');
      }

      final data = response['data'] ?? response;
      return AnalyticsDashboardModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[LaporanService] getAnalyticsDashboard error: $e');
      rethrow;
    }
  }

  /// GET /api/analytics/by-category — Fetch expense categories breakdown
  Future<List<AnalyticsCategoryModel>> getAnalyticsByCategory({
    int? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (month != null) params['month'] = month;
      if (year != null) params['year'] = year;

      final response = await _apiClient.get(
        ApiEndpoints.analyticsByCategory,
        queryParameters: params,
      );

      if (kDebugMode) {
        debugPrint('[LaporanService] Raw analytics by-category response: $response');
      }

      final dynamic rawData = response['data'] ?? response;
      final List<dynamic> list = _extractList(rawData);

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => AnalyticsCategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('[LaporanService] getAnalyticsByCategory error: $e');
      rethrow;
    }
  }

  /// GET /api/analytics/trend — Fetch weekly trends
  Future<List<AnalyticsTrendModel>> getAnalyticsTrend({
    int? month,
    int? year,
    String period = 'weekly',
  }) async {
    try {
      final Map<String, dynamic> params = {'period': period};
      if (month != null) params['month'] = month;
      if (year != null) params['year'] = year;

      final response = await _apiClient.get(
        ApiEndpoints.analyticsTrend,
        queryParameters: params,
      );

      if (kDebugMode) {
        debugPrint('[LaporanService] Raw analytics trend response: $response');
      }

      final dynamic rawData = response['data'] ?? response;
      final List<dynamic> list = _extractList(rawData);

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => AnalyticsTrendModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('[LaporanService] getAnalyticsTrend error: $e');
      rethrow;
    }
  }

  /// POST /api/laporan/export — Generate report PDF url
  Future<Map<String, dynamic>> exportLaporan({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.laporanExport,
        data: {
          'month': month,
          'year': year,
        },
      );

      if (kDebugMode) {
        debugPrint('[LaporanService] Raw export response: $response');
      }

      final data = response['data'] ?? response;
      return data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[LaporanService] exportLaporan error: $e');
      rethrow;
    }
  }

  /// GET /api/laporan/history — Get export history (Optional)
  Future<List<Map<String, dynamic>>> getLaporanHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.laporanHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final dynamic rawData = response['data'] ?? response;
      final List<dynamic> list = _extractList(rawData);

      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('[LaporanService] getLaporanHistory error: $e');
      return [];
    }
  }
}
