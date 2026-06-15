// lib/screens/budget/widgets/budget_set_budget_card.dart

import 'package:flutter/material.dart';

/// Tappable card that opens the budget-settings dialog.
/// Extracted from [BudgetScreen._buildSetBudgetCard].
class BudgetSetBudgetCard extends StatelessWidget {
  final VoidCallback onTap;

  const BudgetSetBudgetCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2E46)),
        ),
        child: const Row(
          children: [
            _TuneIcon(),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atur Anggaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Ubah pendapatan & batas pengeluaran',
                    style:
                        TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF8A99AD)),
          ],
        ),
      ),
    );
  }
}

/// Private const-eligible icon container inside [BudgetSetBudgetCard].
class _TuneIcon extends StatelessWidget {
  const _TuneIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF0C2B29),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.tune_rounded,
        color: Color(0xFF00E5A8),
        size: 22,
      ),
    );
  }
}
