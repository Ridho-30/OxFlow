// lib/screens/dashboard/widgets/dashboard_transaction_list.dart

import 'package:flutter/material.dart';
import '../../../models/transaction/transaction_model.dart';
import 'dashboard_transaction_item.dart';

/// List of recent transactions with an empty-state fallback.
/// Extracted from [DashboardScreen._buildTransactionsList].
class DashboardTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const DashboardTransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
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
      itemBuilder: (_, index) =>
          DashboardTransactionItem(tx: transactions[index]),
    );
  }
}
