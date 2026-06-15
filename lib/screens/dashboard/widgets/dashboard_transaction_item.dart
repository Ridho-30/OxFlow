// lib/screens/dashboard/widgets/dashboard_transaction_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction/transaction_model.dart';

// Module-level formatter — instantiated once, shared across all items.
final _kFmt = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

final _kDateFmt = DateFormat('dd MMMM yyyy', 'id_ID');

// Category names that represent income transactions.
const _kIncomeCategories = {'gaji', 'pemasukan', 'income'};

/// Single row in the recent-transactions list on the Dashboard.
/// Extracted from [DashboardScreen._buildTransactionItem].
class DashboardTransactionItem extends StatelessWidget {
  final TransactionModel tx;

  const DashboardTransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final String category = tx.category?.nameCategory ?? 'Lainnya';
    final bool isIncome =
        _kIncomeCategories.contains(category.toLowerCase());
    final String formattedDate = _kDateFmt.format(tx.date);
    final String storeName =
        (tx.storeName != null && tx.storeName!.trim().isNotEmpty)
            ? tx.storeName!
            : category;

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
                  '$category • $formattedDate',
                  style: const TextStyle(
                      color: Color(0xFF8A99AD), fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  storeName,
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
            isIncome
                ? '+${_kFmt.format(tx.total)}'
                : '-${_kFmt.format(tx.total)}',
            style: TextStyle(
              color: isIncome
                  ? const Color(0xFF00E5A8)
                  : const Color(0xFFFF4D4D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
