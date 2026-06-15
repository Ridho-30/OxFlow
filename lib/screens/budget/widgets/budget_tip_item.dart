// lib/screens/budget/widgets/budget_tip_item.dart

import 'package:flutter/material.dart';
import '../../../models/budget/budget_model.dart';

// ── Data class ────────────────────────────────────────────────────────────────

/// A single financial tip entry.
class BudgetTip {
  final String emoji;
  final String text;

  const BudgetTip({required this.emoji, required this.text});
}

/// Computes the list of tips based on current [BudgetModel] status.
/// Extracted from [BudgetScreen._getTips] so the pure logic is testable.
List<BudgetTip> getTipsForBudget(BudgetModel budget) {
  if (budget.isExceeded) {
    return [
      const BudgetTip(
        emoji: '🔴',
        text:
            'Budget kamu sudah melebihi batas! Tahan pengeluaran tidak penting hingga akhir bulan.',
      ),
      const BudgetTip(
        emoji: '📋',
        text: 'Buat daftar prioritas pengeluaran agar lebih terkontrol.',
      ),
    ];
  }
  if (budget.isWarning) {
    return [
      BudgetTip(
        emoji: '⚠️',
        text:
            'Kamu sudah menggunakan ${budget.percentageUsed}% budget. Hati-hati pengeluaran ke depan!',
      ),
      const BudgetTip(
        emoji: '💡',
        text: 'Coba kurangi pengeluaran hiburan atau makan di luar.',
      ),
    ];
  }
  return const [
    BudgetTip(emoji: '✅', text: 'Budget kamu masih aman. Tetap jaga pengeluaran ya!'),
    BudgetTip(emoji: '💰', text: 'Sisihkan sisa budget untuk tabungan atau investasi.'),
  ];
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// Renders a single financial tip card.
/// Extracted from the inline map in [BudgetScreen._buildTipsSection].
class BudgetTipItem extends StatelessWidget {
  final BudgetTip tip;

  const BudgetTipItem({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF141E2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2E46)),
        ),
        child: Row(
          children: [
            Text(tip.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip.text,
                style: const TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
