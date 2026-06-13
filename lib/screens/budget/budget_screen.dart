import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  // State variables
  double _income = 5000000.0;
  double _totalBudgetLimit = 2000000.0;
  double _totalSpent = 1250000.0;

  // Category limits
  double _limitMakanan = 800000.0;
  double _limitTransport = 500000.0;
  double _limitBelanja = 300000.0;
  double _limitLainnya = 400000.0;

  // Category spent (mocked totals)
  final double _spentMakanan = 500000.0;
  final double _spentTransport = 312500.0;
  final double _spentBelanja = 187500.0;
  final double _spentLainnya = 250000.0;

  void _showAturAnggaranSheet() {
    final incomeController = TextEditingController(
      text: _income.toInt().toString(),
    );
    final makananController = TextEditingController(
      text: _limitMakanan.toInt().toString(),
    );
    final transportController = TextEditingController(
      text: _limitTransport.toInt().toString(),
    );
    final belanjaController = TextEditingController(
      text: _limitBelanja.toInt().toString(),
    );
    final lainnyaController = TextEditingController(
      text: _limitLainnya.toInt().toString(),
    );

    bool isCategoryBudget = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double currentIncome =
                double.tryParse(incomeController.text) ?? 0.0;

            // Suggested categories
            final double suggestMakanan = currentIncome * 0.40;
            final double suggestTransport = currentIncome * 0.25;
            final double suggestBelanja = currentIncome * 0.15;
            final double suggestLainnya = currentIncome * 0.20;

            // Calculate total allocation
            double totalAllocated = 0.0;
            if (isCategoryBudget) {
              final double m = double.tryParse(makananController.text) ?? 0.0;
              final double t = double.tryParse(transportController.text) ?? 0.0;
              final double b = double.tryParse(belanjaController.text) ?? 0.0;
              final double l = double.tryParse(lainnyaController.text) ?? 0.0;
              totalAllocated = m + t + b + l;
            } else {
              totalAllocated = _totalBudgetLimit; // Fallback
            }

            final bool exceedsIncome = totalAllocated > currentIncome;

            // Listener to update suggestions in real time
            incomeController.addListener(() {
              setModalState(() {});
            });
            makananController.addListener(() {
              setModalState(() {});
            });
            transportController.addListener(() {
              setModalState(() {});
            });
            belanjaController.addListener(() {
              setModalState(() {});
            });
            lainnyaController.addListener(() {
              setModalState(() {});
            });

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle and Header
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Atur Anggaran Bulanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF1F2E46)),
                    const SizedBox(height: 16),

                    // Total Pendapatan Field
                    _buildLabel('Total Pendapatan Bulanan'),
                    TextField(
                      controller: incomeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        hint: 'Masukkan estimasi pendapatan',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Toggle: Category budget vs Total budget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tipe Alokasi Anggaran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setModalState(() => isCategoryBudget = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isCategoryBudget
                                      ? const Color(0xFF00E5A8)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Per Kategori',
                                  style: TextStyle(
                                    color: isCategoryBudget
                                        ? Colors.black
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  setModalState(() => isCategoryBudget = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: !isCategoryBudget
                                      ? const Color(0xFF00E5A8)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Total Saja',
                                  style: TextStyle(
                                    color: !isCategoryBudget
                                        ? Colors.black
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (isCategoryBudget) ...[
                      const Text(
                        'BATAS PENGELUARAN PER KATEGORI',
                        style: TextStyle(
                          color: Color(0xFF8A99AD),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category items
                      _buildCategoryField(
                        label: 'Makanan',
                        controller: makananController,
                        suggestedText:
                            'Rekomendasi 40%: Rp ${suggestMakanan.toInt()}',
                      ),
                      _buildCategoryField(
                        label: 'Transportasi',
                        controller: transportController,
                        suggestedText:
                            'Rekomendasi 25%: Rp ${suggestTransport.toInt()}',
                      ),
                      _buildCategoryField(
                        label: 'Belanja',
                        controller: belanjaController,
                        suggestedText:
                            'Rekomendasi 15%: Rp ${suggestBelanja.toInt()}',
                      ),
                      _buildCategoryField(
                        label: 'Lainnya',
                        controller: lainnyaController,
                        suggestedText:
                            'Rekomendasi 20%: Rp ${suggestLainnya.toInt()}',
                      ),
                    ],

                    const SizedBox(height: 12),
                    // Warning status or dynamic allocation total
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: exceedsIncome
                            ? const Color(0xFF3D1F24)
                            : const Color(0xFF0E1724),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            exceedsIncome
                                ? Icons.warning_amber_rounded
                                : Icons.info_outline,
                            color: exceedsIncome
                                ? Colors.redAccent
                                : const Color(0xFF00E5A8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Budget Alokasi: Rp ${totalAllocated.toInt()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                if (exceedsIncome)
                                  const Text(
                                    'Total budget melebihi pendapatan bulanan!',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons inside sheet
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Reset to default suggestion percentages
                              setModalState(() {
                                makananController.text = suggestMakanan
                                    .toInt()
                                    .toString();
                                transportController.text = suggestTransport
                                    .toInt()
                                    .toString();
                                belanjaController.text = suggestBelanja
                                    .toInt()
                                    .toString();
                                lainnyaController.text = suggestLainnya
                                    .toInt()
                                    .toString();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1F2E46)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Reset Rekomendasi',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _income = currentIncome;
                                if (isCategoryBudget) {
                                  _limitMakanan =
                                      double.tryParse(makananController.text) ??
                                      _limitMakanan;
                                  _limitTransport =
                                      double.tryParse(
                                        transportController.text,
                                      ) ??
                                      _limitTransport;
                                  _limitBelanja =
                                      double.tryParse(belanjaController.text) ??
                                      _limitBelanja;
                                  _limitLainnya =
                                      double.tryParse(lainnyaController.text) ??
                                      _limitLainnya;
                                  _totalBudgetLimit =
                                      _limitMakanan +
                                      _limitTransport +
                                      _limitBelanja +
                                      _limitLainnya;
                                } else {
                                  _totalBudgetLimit =
                                      currentIncome * 0.5; // default 50% limit
                                  _limitMakanan = _totalBudgetLimit * 0.40;
                                  _limitTransport = _totalBudgetLimit * 0.25;
                                  _limitBelanja = _totalBudgetLimit * 0.15;
                                  _limitLainnya = _totalBudgetLimit * 0.20;
                                }
                                _totalSpent =
                                    _spentMakanan +
                                    _spentTransport +
                                    _spentBelanja +
                                    _spentLainnya;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Anggaran berhasil diperbarui!',
                                  ),
                                  backgroundColor: Color(0xFF0C2B29),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5A8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLihatRiwayatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Riwayat Anggaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Perubahan Limit Anggaran',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '13 Juni 2026 • Rp 2.000.000',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(Icons.arrow_upward, color: Color(0xFF00E5A8)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Inisiasi Anggaran Bulanan',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '01 Juni 2026 • Rp 1.500.000',
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(Icons.check, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Color(0xFF00E5A8)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHapusSemuaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Semua Anggaran',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua anggaran? Tindakan ini akan mereset limit anggaran Anda ke Rp 0.',
            style: TextStyle(color: Color(0xFF8A99AD)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _totalBudgetLimit = 0;
                  _limitMakanan = 0;
                  _limitTransport = 0;
                  _limitBelanja = 0;
                  _limitLainnya = 0;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua anggaran diset ulang ke Rp 0'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double remainingBudget = _totalBudgetLimit - _totalSpent;
    final double overallProgressPercent = _totalBudgetLimit > 0
        ? (_totalSpent / _totalBudgetLimit)
        : 0;
    final int progressPercentInt = (overallProgressPercent * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Pop-up menu (⋮)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Anggaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Juni 2026',
                        style: TextStyle(
                          color: Color(0xFF8A99AD),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF8A99AD),
                      size: 28,
                    ),
                    // dropdownColor: const Color(0xFF141E2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'atur') {
                        _showAturAnggaranSheet();
                      } else if (value == 'riwayat') {
                        _showLihatRiwayatDialog();
                      } else if (value == 'hapus') {
                        _showHapusSemuaDialog();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'atur',
                          child: Text(
                            'Atur Anggaran',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'riwayat',
                          child: Text(
                            'Lihat Riwayat',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'hapus',
                          child: Text(
                            'Hapus Semua',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Card (Pendapatan, Limit, Sisa)
              _buildSummaryHeaderCard(remainingBudget),
              const SizedBox(height: 20),

              // Atur Anggaran Card (Clickable to open sheet)
              _buildSetBudgetCard(),
              const SizedBox(height: 20),

              // Spending Progress Card
              _buildSpendingProgressCard(progressPercentInt),
              const SizedBox(height: 32),

              // Expense by Category Section
              const Text(
                'PENGELUARAN PER KATEGORI',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              _buildCategoryPieChartSection(),
              const SizedBox(height: 32),

              // Detail per Category Progress Bars Section
              const Text(
                'DETAIL PER KATEGORI',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryProgressBarItem(
                'Makanan',
                _spentMakanan,
                _limitMakanan,
                const Color(0xFF00E5A8),
              ),
              _buildCategoryProgressBarItem(
                'Transportasi',
                _spentTransport,
                _limitTransport,
                const Color(0xFF2F80ED),
              ),
              _buildCategoryProgressBarItem(
                'Belanja',
                _spentBelanja,
                _limitBelanja,
                const Color(0xFFF2C94C),
              ),
              _buildCategoryProgressBarItem(
                'Lainnya',
                _spentLainnya,
                _limitLainnya,
                const Color(0xFFEB5757),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeaderCard(double remainingBudget) {
    final bool isPositive = remainingBudget >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pendapatan Bulanan',
                style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
              ),
              Text(
                'Rp ${_income.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Budget Limit',
                style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
              ),
              Text(
                'Rp ${_totalBudgetLimit.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF1F2E46)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sisa Budget',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rp ${remainingBudget.toInt()}',
                style: TextStyle(
                  color: isPositive
                      ? const Color(0xFF00E5A8)
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetBudgetCard() {
    return InkWell(
      onTap: _showAturAnggaranSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2E46), width: 1),
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
                Icons.settings_outlined,
                color: Color(0xFF00E5A8),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atur anggaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Income: Rp ${_income.toInt()} • Limit: Rp ${_totalBudgetLimit.toInt()}',
                    style: const TextStyle(
                      color: Color(0xFF8A99AD),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8A99AD)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingProgressCard(int progressPercentInt) {
    final bool isWarning = progressPercentInt >= 80;
    final Color progressColor = isWarning
        ? Colors.redAccent
        : const Color(0xFFF2C94C);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terpakai',
                style: TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
              ),
              Text(
                '$progressPercentInt%',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: 'Rp ${_totalSpent.toInt()} ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'dari Rp ${_totalBudgetLimit.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              // value: overallProgressPercent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF0B1220),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (isWarning) ...[
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Mendekati batas anggaran / Melebihi limit!',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryPieChartSection() {
    final double totalLimitVal = _totalBudgetLimit > 0
        ? _totalBudgetLimit
        : 1.0;
    final double pctM = (_limitMakanan / totalLimitVal) * 100;
    final double pctT = (_limitTransport / totalLimitVal) * 100;
    final double pctB = (_limitBelanja / totalLimitVal) * 100;
    final double pctL = (_limitLainnya / totalLimitVal) * 100;

    return Row(
      children: [
        // Pie Chart
        SizedBox(
          width: 130,
          height: 130,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              startDegreeOffset: 270,
              sections: [
                PieChartSectionData(
                  value: _limitMakanan > 0 ? _limitMakanan : 0.1,
                  color: const Color(0xFF00E5A8), // Makanan
                  radius: 65,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: _limitTransport > 0 ? _limitTransport : 0.1,
                  color: const Color(0xFF2F80ED), // Transport
                  radius: 65,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: _limitBelanja > 0 ? _limitBelanja : 0.1,
                  color: const Color(0xFFF2C94C), // Belanja
                  radius: 65,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: _limitLainnya > 0 ? _limitLainnya : 0.1,
                  color: const Color(0xFFEB5757), // Lainnya
                  radius: 65,
                  showTitle: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 28),

        // Legends
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(
                const Color(0xFF00E5A8),
                'Makanan ${pctM.toInt()}%',
              ),
              const SizedBox(height: 12),
              _buildLegendItem(
                const Color(0xFF2F80ED),
                'Transport ${pctT.toInt()}%',
              ),
              const SizedBox(height: 12),
              _buildLegendItem(
                const Color(0xFFF2C94C),
                'Belanja ${pctB.toInt()}%',
              ),
              const SizedBox(height: 12),
              _buildLegendItem(
                const Color(0xFFEB5757),
                'Lainnya ${pctL.toInt()}%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgressBarItem(
    String categoryName,
    double spent,
    double limit,
    Color color,
  ) {
    final double pct = limit > 0 ? (spent / limit) : 0.0;
    final int pctInt = (pct * 100).toInt();
    final double remaining = limit - spent;
    final bool isWarning = pctInt >= 80;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2E46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '$pctInt%',
                style: TextStyle(
                  color: isWarning ? Colors.redAccent : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${spent.toInt()} / Rp ${limit.toInt()}',
                style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 12),
              ),
              Text(
                remaining >= 0
                    ? 'Sisa: Rp ${remaining.toInt()}'
                    : 'Over: Rp ${(-remaining).toInt()}',
                style: TextStyle(
                  color: remaining >= 0
                      ? const Color(0xFF00E5A8)
                      : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFF0B1220),
              valueColor: AlwaysStoppedAnimation<Color>(
                isWarning ? Colors.redAccent : color,
              ),
            ),
          ),
          if (isWarning) ...[
            const SizedBox(height: 6),
            Row(
              children: const [
                Icon(Icons.warning, color: Colors.redAccent, size: 12),
                SizedBox(width: 4),
                Text(
                  'Anggaran kategori ini hampir habis!',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryField({
    required String label,
    required TextEditingController controller,
    required String suggestedText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _buildInputDecoration(hint: 'Rp 0', icon: Icons.money)
                .copyWith(
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(color: Colors.white),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestedText,
            style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 11),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF0B1220),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00E5A8)),
      ),
    );
  }
}
