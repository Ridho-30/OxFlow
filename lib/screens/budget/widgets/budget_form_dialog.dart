// lib/screens/budget/widgets/budget_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ── Shared decoration ─────────────────────────────────────────────────────────

InputDecoration _budgetFieldDecoration({
  required String hint,
  String? prefix,
  IconData? icon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefix,
    prefixStyle: const TextStyle(color: Color(0xFF8A99AD)),
    prefixIcon: icon != null
        ? Icon(icon, color: const Color(0xFF8A99AD), size: 18)
        : null,
    hintStyle:
        const TextStyle(color: Color(0xFF4A5568), fontSize: 14),
    filled: true,
    fillColor: const Color(0xFF0B1220),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1F2E46)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1F2E46)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF00E5A8)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

/// Green hint card (e.g. "Rekomendasi batas: Rp 3.500.000").
class _BudgetHint extends StatelessWidget {
  final String text;

  const _BudgetHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2B29),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Color(0xFF00E5A8), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF00E5A8),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Red warning card shown when threshold exceeds income.
class _ThresholdWarning extends StatelessWidget {
  const _ThresholdWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1F24),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.redAccent, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Batas budget melebihi pendapatan! Tetap lanjut?',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main dialog ───────────────────────────────────────────────────────────────

class BudgetFormDialog extends StatefulWidget {
  final double? initialIncome;
  final double? initialThreshold;
  final Future<void> Function(double income, double threshold) onSubmit;

  const BudgetFormDialog({
    super.key,
    this.initialIncome,
    this.initialThreshold,
    required this.onSubmit,
  });

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _incomeController;
  late final TextEditingController _thresholdController;
  bool _isLoading = false;

  double get _income =>
      double.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0;
  double get _threshold =>
      double.tryParse(_thresholdController.text.replaceAll('.', '')) ?? 0;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(
      text: (widget.initialIncome != null && widget.initialIncome! > 0)
          ? widget.initialIncome!.toInt().toString()
          : '',
    );
    _thresholdController = TextEditingController(
      text: (widget.initialThreshold != null &&
              widget.initialThreshold! > 0)
          ? widget.initialThreshold!.toInt().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSubmit(_income, _threshold);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRp(double value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF141E2E),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Atur Anggaran Bulanan',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan pendapatan bulanan dan batas pengeluaran kamu.',
                style:
                    TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // ── Income field ─────────────────────────────────────────
              const Text(
                'Total Pendapatan Bulanan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _budgetFieldDecoration(
                  hint: 'Contoh: 5000000',
                  prefix: 'Rp ',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                validator: (v) {
                  final val =
                      double.tryParse(v?.replaceAll('.', '') ?? '');
                  if (val == null || val <= 0) {
                    return 'Masukkan pendapatan yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Threshold field ──────────────────────────────────────
              const Text(
                'Batas Budget (Threshold)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _thresholdController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: _budgetFieldDecoration(
                  hint: 'Contoh: 3000000',
                  prefix: 'Rp ',
                  icon: Icons.shield_outlined,
                ),
                validator: (v) {
                  final val =
                      double.tryParse(v?.replaceAll('.', '') ?? '');
                  if (val == null || val <= 0) {
                    return 'Masukkan batas budget yang valid';
                  }
                  return null;
                },
              ),

              // ── Dynamic warnings/hints via ValueListenableBuilder ────
              // Only this subtree rebuilds when either controller changes.
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _thresholdController,
                builder: (context, thresholdVal, child) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _incomeController,
                    builder: (context, incomeVal, child) {
                      final income = double.tryParse(
                              incomeVal.text.replaceAll('.', '')) ??
                          0;
                      final threshold = double.tryParse(
                              thresholdVal.text.replaceAll('.', '')) ??
                          0;

                      if (threshold > income && income > 0) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: _ThresholdWarning(),
                        );
                      }
                      if (income > 0 && threshold == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _BudgetHint(
                            'Rekomendasi batas: ${_formatRp(income * 0.7)} (70% pendapatan)',
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal',
              style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5A8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
}
