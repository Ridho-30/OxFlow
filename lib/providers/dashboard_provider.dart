// lib/providers/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/api_client.dart';
import '../services/dashboard_service.dart';
import '../models/analytics/dashboard_model.dart';
import '../models/transaction/transaction_model.dart';

// ── Service provider ────────────────────────────────────────────────────────
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ApiClient());
});

// ── Dashboard state ──────────────────────────────────────────────────────────
class DashboardState {
  final bool isLoading;
  final DashboardModel? dashboardData;
  final List<TransactionModel> recentTransactions;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.dashboardData,
    this.recentTransactions = const [],
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardModel? dashboardData,
    List<TransactionModel>? recentTransactions,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      dashboardData: dashboardData ?? this.dashboardData,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(loadDashboardData);
    return const DashboardState(isLoading: true);
  }

  DashboardService get _service => ref.read(dashboardServiceProvider);

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dashboard = await _service.getDashboardData();
      final recent = await _service.getRecentTransactions(limit: 4);
      state = DashboardState(
        isLoading: false,
        dashboardData: dashboard,
        recentTransactions: recent,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ────────────────────────────────────────────────────────────────
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
