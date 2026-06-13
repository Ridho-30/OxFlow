// lib/services/budget_service.dart

import 'api/api_client.dart';
import 'api/api_endpoints.dart';
import '../models/budget/budget_model.dart';
import '../models/budget/budget_request.dart';

class BudgetService {
  final ApiClient _apiClient;

  BudgetService(this._apiClient);

  /// GET /api/budget — budget info + spending stats for this month
  Future<BudgetModel> getBudget() async {
    final response = await _apiClient.get(ApiEndpoints.budget);
    final data = response['data'] ?? response;
    return BudgetModel.fromJson(data as Map<String, dynamic>);
  }

  /// GET /api/budget/status — lightweight status check
  Future<Map<String, dynamic>> getBudgetStatus() async {
    final response = await _apiClient.get(ApiEndpoints.budgetStatus);
    return (response['data'] ?? response) as Map<String, dynamic>;
  }

  /// POST /api/budget — create if none exists, update if it does
  Future<BudgetModel> setBudget({
    required double income,
    required double threshold,
  }) async {
    final request = BudgetRequest(income: income, threshold: threshold);
    final response = await _apiClient.post(
      ApiEndpoints.budget,
      data: request.toJson(),
    );

    // After POST the backend returns only the stored record (no spending stats),
    // so we re-fetch the full budget to get the complete picture.
    try {
      return await getBudget();
    } catch (_) {
      // Fall back to parsing POST response if GET fails
      final data = response['data'] ?? response;
      return BudgetModel.fromJson(data as Map<String, dynamic>);
    }
  }
}
