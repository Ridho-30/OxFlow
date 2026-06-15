// lib/screens/laporan/widgets/laporan_harian_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/laporan_provider.dart';
import '../../../models/transaction/transaction_model.dart';
import '../utils/laporan_utils.dart';
import 'laporan_shimmer.dart';
import 'laporan_common_widgets.dart';
import 'laporan_transaction_detail_sheet.dart';

/// Full Harian (Daily) tab content.
/// Extracted from [LaporanScreen._buildHarianTab].
class LaporanHarianTab extends ConsumerWidget {
  const LaporanHarianTab({super.key});

  void _changeDate(WidgetRef ref, LaporanState state, int days) {
    ref.read(laporanProvider.notifier).changeDate(
          state.currentDate.add(Duration(days: days)),
        );
  }

  void _handleSwipe(DragEndDetails details, WidgetRef ref, LaporanState state) {
    if (details.primaryVelocity == null) return;
    final days = details.primaryVelocity! < 0 ? 1 : -1;
    _changeDate(ref, state, days);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);

    if (state.isDailyLoading) return const LaporanShimmer();

    if (state.dailyError != null) {
      return LaporanErrorState(
        errorMsg: state.dailyError!,
        onRetry: () =>
            ref.read(laporanProvider.notifier).fetchDailyTransactions(),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (d) => _handleSwipe(d, ref, state),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date navigator ─────────────────────────────────────────
          _DateNavigator(
            label: formatIndonesianDate(state.currentDate),
            onPrev: () => _changeDate(ref, state, -1),
            onNext: () => _changeDate(ref, state, 1),
          ),
          const SizedBox(height: 24),

          // ── Transaction list ───────────────────────────────────────
          const Text(
            'TRANSAKSI HARI INI',
            style: TextStyle(
              color: Color(0xFF8A99AD),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          if (state.dailyTransactions.isEmpty)
            const LaporanEmptyState(
                message: 'Tidak ada transaksi pada tanggal ini')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.dailyTransactions.length,
              itemBuilder: (_, index) => _HarianTransactionCard(
                tx: state.dailyTransactions[index],
                onTap: () => showTransactionDetailSheet(
                  context,
                  ref,
                  state.dailyTransactions[index].id,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Date navigator ────────────────────────────────────────────────────────────

class _DateNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateNavigator({
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

// ── Harian transaction card ───────────────────────────────────────────────────

class _HarianTransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onTap;

  const _HarianTransactionCard({
    required this.tx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryName = tx.category?.nameCategory ?? 'Lainnya';
    final bool isIncome = isIncomeCategory(categoryName);
    final IconData icon = getCategoryIcon(categoryName);
    final String time = tx.createdAt != null
        ? DateFormat('HH:mm').format(tx.createdAt!.toLocal())
        : DateFormat('HH:mm').format(tx.date);

    return Card(
      color: const Color(0xFF141E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0B1220),
          child: Icon(icon, color: const Color(0xFF00E5A8), size: 20),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              '$categoryName • $time',
              style: const TextStyle(
                  color: Color(0xFF8A99AD), fontSize: 12),
            ),
            if (tx.fotoStruk != null && tx.fotoStruk!.isNotEmpty) ...[
              const SizedBox(width: 8),
              const Icon(Icons.receipt_long,
                  color: Color(0xFF00E5A8), size: 14),
            ],
          ],
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
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
