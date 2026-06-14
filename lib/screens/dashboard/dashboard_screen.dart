// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/analytics/dashboard_model.dart';
import '../../models/transaction/transaction_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final dashboard = state.dashboardData;
    final recentTransactions = state.recentTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardProvider.notifier).loadDashboardData();
          },
          color: const Color(0xFF00E5A8),
          backgroundColor: const Color(0xFF141E2E),
          child: state.isLoading && dashboard == null
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00E5A8),
                    ),
                  ),
                )
              : state.error != null && dashboard == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(dashboardProvider.notifier)
                              .loadDashboardData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5A8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    _getFallbackMonthLabel(),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00E5A8),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Total Expense Card
                      _buildTotalExpenseCard(
                        dashboard?.summary.totalSpent ?? 0.0,
                      ),
                      const SizedBox(height: 16),

                      // Sisa Anggaran & Status row
                      _buildStatsRow(dashboard?.summary),
                      const SizedBox(height: 32),

                      // Weekly Expense Section
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
                      _buildWeeklyChartSection(dashboard?.weeklyChart ?? []),
                      const SizedBox(height: 32),

                      // Recent Transactions Section
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

                      // Transaction List
                      _buildTransactionsList(recentTransactions),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  String _getFallbackMonthLabel() {
    return DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  Widget _buildTotalExpenseCard(double totalSpent) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total pengeluaran bulan ini',
            style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(totalSpent),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DashboardSummaryModel? summary) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final double remaining = summary?.remaining ?? 0.0;
    final String status = summary?.status ?? 'normal';

    final Color statusColor = status == 'danger'
        ? const Color(0xFFEB5757)
        : status == 'warning'
        ? const Color(0xFFF2C94C)
        : const Color(0xFF00E5A8);

    final String statusText = status == 'danger'
        ? 'Bahaya'
        : status == 'warning'
        ? 'Peringatan'
        : 'Aman';

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: 'Sisa anggaran',
            value: fmt.format(remaining),
            valueColor: remaining < 0
                ? const Color(0xFFEB5757)
                : const Color(0xFF00E5A8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            title: 'Status',
            value: statusText,
            valueColor: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartSection(
    List<DashboardWeeklyChartItemModel> weeklyChart,
  ) {
    if (weeklyChart.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF141E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2E46)),
        ),
        child: const Text(
          'Belum ada data pengeluaran minggu ini',
          style: TextStyle(color: Color(0xFF8A99AD)),
        ),
      );
    }

    double maxSpent = weeklyChart
        .map((e) => e.total)
        .reduce((a, b) => a > b ? a : b);
    if (maxSpent <= 0) maxSpent = 1000.0;
    final double maxY = maxSpent * 1.15;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipColor: (_) => const Color(0xFF141E2E),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final fmt = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );
                return BarTooltipItem(
                  fmt.format(rod.toY),
                  const TextStyle(
                    color: Color(0xFF00E5A8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= weeklyChart.length) {
                    return const SizedBox.shrink();
                  }

                  final item = weeklyChart[index];
                  String label = item.day;
                  if (label.length > 3) {
                    label = label.substring(0, 3);
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF8A99AD),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(weeklyChart.length, (index) {
            final item = weeklyChart[index];
            return _makeBarGroup(index, item.total, maxY);
          }),
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, double maxY) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF00E5A8),
          width: 14,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: const Color(0xFF141E2E),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: Colors.grey.shade600,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada transaksi terbaru',
              style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFF1F2E46), height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _buildTransactionItem(
          category: tx.category?.nameCategory ?? 'Lainnya',
          title: tx.title,
          amount: tx.total,
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required String category,
    required String title,
    required double amount,
  }) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '-${fmt.format(amount)}',
            style: const TextStyle(
              color: Color(0xFFFF4D4D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
