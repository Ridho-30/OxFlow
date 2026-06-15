// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/dashboard_expense_card.dart';
import 'widgets/dashboard_stats_row.dart';
import 'widgets/dashboard_weekly_chart.dart';
import 'widgets/dashboard_transaction_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final dashboard = state.dashboardData;
    final recentTransactions = state.recentTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardProvider.notifier).loadDashboardData(),
          color: const Color(0xFF00E5A8),
          backgroundColor: const Color(0xFF141E2E),
          child: state.isLoading && dashboard == null
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E5A8)),
                  ),
                )
              : state.error != null && dashboard == null
                  ? _DashboardErrorState(
                      message: state.error!,
                      onRetry: () => ref
                          .read(dashboardProvider.notifier)
                          .loadDashboardData(),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header ───────────────────────────────────
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Beranda',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dashboard?.thisMonthInfo.monthLabel ??
                                        DateFormat('MMMM yyyy', 'id_ID')
                                            .format(DateTime.now()),
                                    style: const TextStyle(
                                      color: Color(0xFF8A99AD),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              if (state.isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Color(0xFF00E5A8)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ── Total expense card ────────────────────
                          DashboardExpenseCard(
                            totalSpent:
                                dashboard?.summary.totalSpent ?? 0.0,
                          ),
                          const SizedBox(height: 16),

                          // ── Stats row ─────────────────────────────
                          DashboardStatsRow(summary: dashboard?.summary),
                          const SizedBox(height: 32),

                          // ── Weekly chart ──────────────────────────
                          const Text(
                            'PENGELUARAN MINGGUAN',
                            style: TextStyle(
                              color: Color(0xFF8A99AD),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DashboardWeeklyChart(
                            weeklyChart: dashboard?.weeklyChart ?? [],
                          ),
                          const SizedBox(height: 32),

                          // ── Recent transactions ───────────────────
                          const Text(
                            'TRANSAKSI TERBARU',
                            style: TextStyle(
                              color: Color(0xFF8A99AD),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DashboardTransactionList(
                            transactions: recentTransactions,
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

// ── Private error state ───────────────────────────────────────────────────────

/// Inline error widget — kept private since it's only used here.
/// Extracted from the 60-line inline widget tree in the original build().
class _DashboardErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5A8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
