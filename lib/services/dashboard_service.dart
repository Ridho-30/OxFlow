// lib/services/dashboard_service.dart

import 'package:flutter/foundation.dart';
import 'api/api_client.dart';
import 'api/api_endpoints.dart';
import '../models/analytics/dashboard_model.dart';
import '../models/transaction/transaction_model.dart';
import '../models/transaction/category_model.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  /// GET /api/analytics/dashboard
  Future<DashboardModel> getDashboardData() async {
    final response = await _apiClient.get(ApiEndpoints.analyticsDashboard);
    final data = response['data'] ?? response;
    return DashboardModel.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/categories — returns Map of categoryId to categoryName
  Future<Map<int, String>> _fetchCategoryLookup() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);

      if (kDebugMode) {
        debugPrint('[DashboardService] Raw categories response: $response');
      }

      // Walk the response to find the list — handle all common wrapper formats
      final list = _extractList(response);

      if (kDebugMode) {
        debugPrint('[DashboardService] Extracted category list (${list.length} items): $list');
      }

      final Map<int, String> lookup = {};
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final cat = CategoryModel.fromJson(item);
            if (cat.id != 0 && cat.nameCategory.isNotEmpty) {
              lookup[cat.id] = cat.nameCategory;
            }
          } catch (e) {
            debugPrint('[DashboardService] Failed to parse category item: $item — $e');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('[DashboardService] Category lookup map: $lookup');
      }

      return lookup;
    } catch (e) {
      debugPrint('[DashboardService] _fetchCategoryLookup error: $e');
      return {};
    }
  }

  /// Recursively search for a List inside a nested map/list response.
  List<dynamic> _extractList(dynamic value) {
    if (value is List) return value;

    if (value is Map<String, dynamic>) {
      // Common keys to look for
      for (final key in ['data', 'categories', 'items', 'result', 'results']) {
        if (value[key] != null) {
          final found = _extractList(value[key]);
          if (found.isNotEmpty) return found;
        }
      }
    }

    return [];
  }

  /// GET /api/transactions — fetch recent transactions with resolved category names
  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    try {
      // Fetch categories and transactions concurrently
      final categoryLookup = await _fetchCategoryLookup();

      final response = await _apiClient.get(
        ApiEndpoints.transactions,
        queryParameters: {
          'limit': limit,
          'sort': 'date_desc',
        },
      );

      if (kDebugMode) {
        debugPrint('[DashboardService] Raw transactions response: $response');
      }

      final list = _extractList(response);

      if (kDebugMode) {
        debugPrint('[DashboardService] Extracted transaction list (${list.length} items)');
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => TransactionModel.fromJsonWithCategories(
                item,
                categoryLookup,
              ))
          .toList();
    } catch (e) {
      debugPrint('[DashboardService] getRecentTransactions error: $e');
      return [];
    }
  }
}
