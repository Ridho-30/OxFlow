// lib/screens/budget/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget/budget_model.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/budget_form_dialog.dart';
import 'widgets/budget_no_budget_state.dart';
import 'widgets/budget_error_state.dart';
import 'widgets/budget_tip_item.dart';
import 'widgets/budget_set_budget_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  // ── Dialog helper ─────────────────────────────────────────────────────────

  void _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetModel? existing,
  ) {
    showDialog(
      context: context,
      builder: (_) => BudgetFormDialog(
        initialIncome: existing?.income,
        initialThreshold: existing?.threshold,
        onSubmit: (income, threshold) async {
          await ref
              .read(budgetProvider.notifier)
              .setBudget(income: income, threshold: threshold);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Anggaran berhasil disimpan!'),
                backgroundColor: Color(0xFF0C2B29),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: budgetState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5A8)),
              )
            : budgetState.error != null
                ? BudgetErrorState(
                    message: budgetState.error!,
                    onRetry: () =>
                        ref.read(budgetProvider.notifier).loadBudget(),
                  )
                : budgetState.hasNoBudget
                    ? BudgetNoBudgetState(
                        onCreateBudget: () =>
                            _showBudgetDialog(context, ref, null),
                      )
                    : _BudgetContent(
                        budget: budgetState.budget!,
                        onOpenDialog: (budget) =>
                            _showBudgetDialog(context, ref, budget),
                        onRefresh: () =>
                            ref.read(budgetProvider.notifier).loadBudget(),
                      ),
      ),
    );
  }
}

// ── Private content widget ────────────────────────────────────────────────────

/// Main content shown when a budget exists.
/// Kept private to this file — not intended for reuse elsewhere.
class _BudgetContent extends StatelessWidget {
  final BudgetModel budget;
  final void Function(BudgetModel) onOpenDialog;
  final Future<void> Function() onRefresh;

  const _BudgetContent({
    required this.budget,
    required this.onOpenDialog,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now());
    final tips = getTipsForBudget(budget);

    return RefreshIndicator(
      color: const Color(0xFF00E5A8),
      backgroundColor: const Color(0xFF141E2E),
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anggaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthLabel,
                      style: const TextStyle(
                        color: Color(0xFF8A99AD),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                _BudgetMenuButton(
                  onEdit: () => onOpenDialog(budget),
                  onRefresh: onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Summary card ─────────────────────────────────────────────
            BudgetSummaryCard(budget: budget),
            const SizedBox(height: 20),

            // ── Quick-set card ───────────────────────────────────────────
            BudgetSetBudgetCard(onTap: () => onOpenDialog(budget)),
            const SizedBox(height: 32),

            // ── Tips section ─────────────────────────────────────────────
            if (tips.isNotEmpty) ...[
              const Text(
                'TIPS KEUANGAN:',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...tips.map((tip) => BudgetTipItem(tip: tip)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Private menu button widget ────────────────────────────────────────────────

class _BudgetMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onRefresh;

  const _BudgetMenuButton({
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF8A99AD), size: 28),
      color: const Color(0xFF141E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'atur') {
          onEdit();
        } else if (value == 'refresh') {
          onRefresh();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'atur',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Color(0xFF00E5A8), size: 18),
              SizedBox(width: 10),
              Text('Atur Anggaran', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, color: Color(0xFF8A99AD), size: 18),
              SizedBox(width: 10),
              Text('Refresh', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
