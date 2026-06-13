// lib/screens/budget/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../models/budget/budget_model.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/budget_form_dialog.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: budgetState.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E5A8),
                ),
              )
            : budgetState.error != null
                ? _buildError(context, ref, budgetState.error!)
                : budgetState.hasNoBudget
                    ? _buildNoBudget(context, ref)
                    : _buildContent(context, ref, budgetState.budget!),
      ),
    );
  }

  // ── Content ──────────────────────────────────────────────────────────────

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) {
    final now = DateTime.now();
    final monthLabel =
        DateFormat('MMMM yyyy', 'id_ID').format(now);

    return RefreshIndicator(
      color: const Color(0xFF00E5A8),
      backgroundColor: const Color(0xFF141E2E),
      onRefresh: () => ref.read(budgetProvider.notifier).loadBudget(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
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
                _buildMenuButton(context, ref, budget),
              ],
            ),
            const SizedBox(height: 24),

            // ── Summary card ──
            BudgetSummaryCard(budget: budget),
            const SizedBox(height: 20),

            // ── Quick-set card ──
            _buildSetBudgetCard(context, ref, budget),
            const SizedBox(height: 32),

            // ── Tips section ──
            _buildTipsSection(budget),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Menu ─────────────────────────────────────────────────────────────────

  Widget _buildMenuButton(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Color(0xFF8A99AD), size: 28),
      color: const Color(0xFF141E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'atur') {
          _showBudgetDialog(context, ref, budget);
        } else if (value == 'refresh') {
          ref.read(budgetProvider.notifier).loadBudget();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'atur',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Color(0xFF00E5A8), size: 18),
              SizedBox(width: 10),
              Text('Atur Anggaran', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
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

  // ── Quick-set card ────────────────────────────────────────────────────────

  Widget _buildSetBudgetCard(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) {
    return InkWell(
      onTap: () => _showBudgetDialog(context, ref, budget),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2E46)),
        ),
        child: Row(
          children: [
            Container(
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
            ),
            const SizedBox(width: 16),
            const Expanded(
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
                    style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF8A99AD),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tips section ──────────────────────────────────────────────────────────

  Widget _buildTipsSection(BudgetModel budget) {
    final tips = _getTips(budget);
    if (tips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPS KEUANGAN',
          style: TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map(
          (tip) => Padding(
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
                  Text(tip['emoji']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip['text']!,
                      style: const TextStyle(
                        color: Color(0xFF8A99AD),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> _getTips(BudgetModel budget) {
    if (budget.isExceeded) {
      return [
        {
          'emoji': '🔴',
          'text':
              'Budget kamu sudah melebihi batas! Tahan pengeluaran tidak penting hingga akhir bulan.',
        },
        {
          'emoji': '📋',
          'text':
              'Buat daftar prioritas pengeluaran agar lebih terkontrol.',
        },
      ];
    } else if (budget.isWarning) {
      return [
        {
          'emoji': '⚠️',
          'text':
              'Kamu sudah menggunakan ${budget.percentageUsed}% budget. Hati-hati pengeluaran ke depan!',
        },
        {
          'emoji': '💡',
          'text': 'Coba kurangi pengeluaran hiburan atau makan di luar.',
        },
      ];
    }
    return [
      {
        'emoji': '✅',
        'text':
            'Budget kamu masih aman. Tetap jaga pengeluaran ya!',
      },
      {
        'emoji': '💰',
        'text':
            'Sisihkan sisa budget untuk tabungan atau investasi.',
      },
    ];
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildNoBudget(BuildContext context, WidgetRef ref) {
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
                onPressed: () => _showBudgetDialog(context, ref, null),
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

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(budgetProvider.notifier).loadBudget(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5A8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog ────────────────────────────────────────────────────────────────

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
          final notifier = ref.read(budgetProvider.notifier);
          await notifier.setBudget(income: income, threshold: threshold);

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
}
