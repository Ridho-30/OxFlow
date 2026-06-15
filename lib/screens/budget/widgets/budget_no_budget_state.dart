// lib/screens/budget/widgets/budget_no_budget_state.dart

import 'package:flutter/material.dart';

/// Empty-state widget shown when the user has no budget configured yet.
/// Extracted from [BudgetScreen._buildNoBudget].
/// Fully const-eligible — no dynamic content.
class BudgetNoBudgetState extends StatelessWidget {
  final VoidCallback onCreateBudget;

  const BudgetNoBudgetState({
    super.key,
    required this.onCreateBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF141E2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF00E5A8),
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Anggaran',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Atur anggaran bulananmu untuk mulai melacak pengeluaran dan menjaga keuangan tetap sehat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5A8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text(
                  'Buat Anggaran Sekarang',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
