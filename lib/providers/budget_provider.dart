// lib/providers/budget_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/api_client.dart';
import '../services/budget_service.dart';
import '../models/budget/budget_model.dart';

// ── Service provider ────────────────────────────────────────────────────────
final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService(ApiClient());
});

// ── Budget state ────────────────────────────────────────────────────────────
class BudgetState {
  final bool isLoading;
  final BudgetModel? budget;
  final String? error;
  final bool hasNoBudget; // true when the server returned 404

  const BudgetState({
    this.isLoading = false,
    this.budget,
    this.error,
    this.hasNoBudget = false,
  });

  BudgetState copyWith({
    bool? isLoading,
    BudgetModel? budget,
    String? error,
    bool? hasNoBudget,
    bool clearError = false,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading,
      budget: budget ?? this.budget,
      error: clearError ? null : (error ?? this.error),
      hasNoBudget: hasNoBudget ?? this.hasNoBudget,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────
class BudgetNotifier extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    Future.microtask(loadBudget);
    return const BudgetState(isLoading: true);
  }

  BudgetService get _service => ref.read(budgetServiceProvider);

  Future<void> loadBudget() async {
    state = state.copyWith(isLoading: true, clearError: true, hasNoBudget: false);
    try {
      final budget = await _service.getBudget();
      state = state.copyWith(isLoading: false, budget: budget);
    } on NotFoundException {
      // Budget not yet created for this user
      state = state.copyWith(isLoading: false, hasNoBudget: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setBudget({
    required double income,
    required double threshold,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final budget = await _service.setBudget(
        income: income,
        threshold: threshold,
      );
      state = state.copyWith(isLoading: false, budget: budget, hasNoBudget: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ────────────────────────────────────────────────────────────────
final budgetProvider = NotifierProvider<BudgetNotifier, BudgetState>(
  BudgetNotifier.new,
);
