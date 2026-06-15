// lib/screens/dashboard/widgets/dashboard_expense_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Large card at the top of the Dashboard showing total monthly spending.
/// Extracted from [DashboardScreen._buildTotalExpenseCard].
class DashboardExpenseCard extends StatelessWidget {
  final double totalSpent;

  const DashboardExpenseCard({super.key, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalSpent);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2E46)),
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
            formatted,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
