// lib/screens/budget/widgets/budget_summary_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/budget/budget_model.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetModel budget;

  const BudgetSummaryCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final progress = (budget.percentageUsed / 100).clamp(0.0, 1.0);
    final Color statusColor = budget.isExceeded
        ? const Color(0xFFEB5757)
        : budget.isWarning
            ? const Color(0xFFF2C94C)
            : const Color(0xFF00E5A8);

    final String statusLabel = budget.isExceeded
        ? '🔴 MELEBIHI BATAS'
        : budget.isWarning
            ? '⚠️ PERINGATAN'
            : '✅ AMAN';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2E46)),
      ),
      child: Column(
        children: [
          // ── Status banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Key metrics row ──
                Row(
                  children: [
                    _MetricTile(
                      label: 'Pendapatan',
                      value: fmt.format(budget.income),
                      color: Colors.white,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(width: 12),
                    _MetricTile(
                      label: 'Batas Budget',
                      value: fmt.format(budget.threshold),
                      color: const Color(0xFF2F80ED),
                      icon: Icons.shield_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MetricTile(
                      label: 'Terpakai',
                      value: fmt.format(budget.totalSpentThisMonth),
                      color: statusColor,
                      icon: Icons.trending_up_rounded,
                    ),
                    const SizedBox(width: 12),
                    _MetricTile(
                      label: 'Sisa',
                      value: fmt.format(budget.remaining),
                      color: budget.remaining < 0
                          ? const Color(0xFFEB5757)
                          : const Color(0xFF00E5A8),
                      icon: Icons.savings_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Progress bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress Pengeluaran',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${budget.percentageUsed}%',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFF1F2E46),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),

                if (budget.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: statusColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            budget.description,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2E46)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
