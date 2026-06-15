// lib/screens/laporan/widgets/laporan_mingguan_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/laporan_provider.dart';
import '../../../models/transaction/transaction_model.dart';
import '../utils/laporan_utils.dart';
import 'laporan_shimmer.dart';
import 'laporan_common_widgets.dart';
import 'laporan_transaction_detail_sheet.dart';

/// Full Mingguan (Weekly) tab content.
/// Extracted from [LaporanScreen._buildMingguanTab].
///
/// Uses [ConsumerStatefulWidget] because `_expandedDayIndex` state was
/// previously held on the root screen — now correctly scoped here.
class LaporanMingguanTab extends ConsumerStatefulWidget {
  const LaporanMingguanTab({super.key});

  @override
  ConsumerState<LaporanMingguanTab> createState() =>
      _LaporanMingguanTabState();
}

class _LaporanMingguanTabState
    extends ConsumerState<LaporanMingguanTab> {
  int _expandedDayIndex = -1;

  void _changeWeek(LaporanState state, int days) {
    ref.read(laporanProvider.notifier).changeDate(
          state.currentDate.add(Duration(days: days)),
        );
  }

  void _handleSwipe(DragEndDetails details, LaporanState state) {
    if (details.primaryVelocity == null) return;
    final days = details.primaryVelocity! < 0 ? 7 : -7;
    _changeWeek(state, days);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(laporanProvider);

    if (state.isWeeklyLoading) return const LaporanShimmer();

    if (state.weeklyError != null) {
      return LaporanErrorState(
        errorMsg: state.weeklyError!,
        onRetry: () =>
            ref.read(laporanProvider.notifier).fetchWeeklyTransactions(),
      );
    }

    // ── Compute weekly totals ─────────────────────────────────────────────
    final weeklyTxs = state.weeklyTransactions;
    double totalWeeklyExpense = 0;
    for (final tx in weeklyTxs) {
      if (!isIncomeCategory(tx.category?.nameCategory ?? '')) {
        totalWeeklyExpense += tx.total;
      }
    }
    final double avgDailyExpense = totalWeeklyExpense / 7;

    // ── Group transactions by day (Mon–Sun) ───────────────────────────────
    final monday = state.currentDate.subtract(
      Duration(days: state.currentDate.weekday - 1),
    );
    final DateFormat dateFmt = DateFormat('yyyy-MM-dd');
    final Map<String, List<TransactionModel>> grouped = {
      for (int i = 0; i < 7; i++)
        dateFmt.format(monday.add(Duration(days: i))): [],
    };
    for (final tx in weeklyTxs) {
      final key = dateFmt.format(tx.date);
      if (grouped.containsKey(key)) grouped[key]!.add(tx);
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (d) => _handleSwipe(d, state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Week navigator ──────────────────────────────────────────
          _WeekNavigator(
            label: formatWeekRange(state.currentDate),
            onPrev: () => _changeWeek(state, -7),
            onNext: () => _changeWeek(state, 7),
          ),
          const SizedBox(height: 16),

          // ── Weekly summary card ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF141E2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1F2E46)),
            ),
            child: Column(
              children: [
                LaporanSummaryRow(
                  label: 'Total Pengeluaran',
                  value: formatCurrency(totalWeeklyExpense),
                  valueColor: Colors.redAccent,
                ),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFF1F2E46)),
                const SizedBox(height: 10),
                LaporanSummaryRow(
                  label: 'Rata-rata Harian',
                  value: formatCurrency(avgDailyExpense),
                  valueColor: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Daily breakdown list ────────────────────────────────────
          const Text(
            'RINCIAN PENGELUARAN HARIAN',
            style: TextStyle(
              color: Color(0xFF8A99AD),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grouped.length,
            itemBuilder: (_, index) {
              final dateStr = grouped.keys.elementAt(index);
              final dayTxs = grouped[dateStr]!;
              final parsedDate = DateTime.parse(dateStr);
              final dayLabel =
                  DateFormat('EEEE, dd MMM', 'id_ID').format(parsedDate);

              double daySpent = 0;
              for (final tx in dayTxs) {
                if (!isIncomeCategory(tx.category?.nameCategory ?? '')) {
                  daySpent += tx.total;
                }
              }

              return _WeeklyDayCard(
                index: index,
                dayLabel: dayLabel,
                daySpent: daySpent,
                transactions: dayTxs,
                isExpanded: _expandedDayIndex == index,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedDayIndex = expanded ? index : -1;
                  });
                },
                onTransactionTap: (txId) =>
                    showTransactionDetailSheet(context, ref, txId),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Week navigator ────────────────────────────────────────────────────────────

class _WeekNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _WeekNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF00E5A8)),
          onPressed: onPrev,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Color(0xFF00E5A8)),
          onPressed: onNext,
        ),
      ],
    );
  }
}

// ── Weekly day card (ExpansionTile) ──────────────────────────────────────────

class _WeeklyDayCard extends StatelessWidget {
  final int index;
  final String dayLabel;
  final double daySpent;
  final List<TransactionModel> transactions;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;
  final ValueChanged<String> onTransactionTap;

  const _WeeklyDayCard({
    required this.index,
    required this.dayLabel,
    required this.daySpent,
    required this.transactions,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF141E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data:
            Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<int>(index),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          title: Text(
            dayLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrency(daySpent),
                style: TextStyle(
                  color: daySpent > 0 ? Colors.redAccent : Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF8A99AD),
                size: 18,
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0E1724),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14)),
              ),
              child: transactions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Tidak ada transaksi di hari ini',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                  : Column(
                      children: transactions.map((tx) {
                        final bool isIncome = isIncomeCategory(
                            tx.category?.nameCategory ?? '');
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onTap: () => onTransactionTap(tx.id),
                          leading: const Icon(
                            Icons.subdirectory_arrow_right,
                            size: 14,
                            color: Color(0xFF00E5A8),
                          ),
                          title: Text(
                            tx.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            tx.category?.nameCategory ?? 'Lainnya',
                            style: const TextStyle(
                              color: Color(0xFF8A99AD),
                              fontSize: 11,
                            ),
                          ),
                          trailing: Text(
                            isIncome
                                ? '+${formatCurrency(tx.total)}'
                                : '-${formatCurrency(tx.total)}',
                            style: TextStyle(
                              color: isIncome
                                  ? const Color(0xFF00E5A8)
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
