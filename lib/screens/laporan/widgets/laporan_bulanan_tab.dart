// lib/screens/laporan/widgets/laporan_bulanan_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/laporan_provider.dart';
import '../../../models/analytics/analytics_category_model.dart';
import '../utils/laporan_utils.dart';
import 'laporan_shimmer.dart';
import 'laporan_common_widgets.dart';

/// Full Bulanan (Monthly) tab content.
/// Extracted from [LaporanScreen._buildBulananTab].
class LaporanBulananTab extends ConsumerWidget {
  final VoidCallback onDownloadPdf;

  const LaporanBulananTab({super.key, required this.onDownloadPdf});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(laporanProvider);

    if (state.isMonthlyLoading) return const LaporanShimmer();

    if (state.monthlyError != null) {
      return LaporanErrorState(
        errorMsg: state.monthlyError!,
        onRetry: () =>
            ref.read(laporanProvider.notifier).fetchMonthlyData(),
      );
    }

    final String currentMonthLabel =
        '${kMonthNames[state.selectedMonth - 1]} ${state.selectedYear}';

    final db = state.monthlyDashboard;
    final categories = state.monthlyCategories.where((cat) => cat.total > 0).toList();

    final double expense = db?.totalExpense ?? 0;

    // Compute average daily — use API value if > 0, else divide by days in month
    double avgDaily = db?.avgDailyExpense ?? 0;
    if (avgDaily == 0 && expense > 0) {
      final daysInMonth =
          DateTime(state.selectedYear, state.selectedMonth + 1, 0).day;
      avgDaily = expense / daysInMonth;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Month navigator ───────────────────────────────────────────
        _MonthNavigator(
          label: currentMonthLabel,
          onPrev: () {
            int m = state.selectedMonth - 1;
            int y = state.selectedYear;
            if (m < 1) {
              m = 12;
              y -= 1;
            }
            ref.read(laporanProvider.notifier).changeMonthYear(m, y);
          },
          onNext: () {
            int m = state.selectedMonth + 1;
            int y = state.selectedYear;
            if (m > 12) {
              m = 1;
              y += 1;
            }
            ref.read(laporanProvider.notifier).changeMonthYear(m, y);
          },
          onTapLabel: () {
            _showMonthYearPicker(context, ref, state.selectedMonth, state.selectedYear);
          },
        ),
        const SizedBox(height: 16),

        // ── Monthly summary card ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2E46)),
          ),
          child: Column(
            children: [
              LaporanSummaryRow(
                label: 'Total Pengeluaran',
                value: formatCurrency(expense),
                valueColor: Colors.redAccent,
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF1F2E46)),
              const SizedBox(height: 10),
              LaporanSummaryRow(
                label: 'Rata-rata Harian',
                value: formatCurrency(avgDaily),
                valueColor: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Pie chart section ─────────────────────────────────────────
        const Text(
          'DISTRIBUSI PENGELUARAN BULANAN',
          style: TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),

        if (categories.isEmpty)
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF141E2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1F2E46)),
            ),
            child: const Text(
              'Belum ada data distribusi kategori',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          _BulananPieSection(categories: categories),

        const SizedBox(height: 28),

        // ── Category progress list ────────────────────────────────────
        const Text(
          'RINCIAN KATEGORI BULANAN',
          style: TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2E46)),
          ),
          child: categories.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada rincian kategori',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  children: categories.asMap().entries.map((entry) {
                    final isLast = entry.key == categories.length - 1;
                    final cat = entry.value;
                    final color =
                        getCategoryColor(cat.categoryId, cat.categoryName);
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                      child: LaporanCategoryProgressItem(
                        label: cat.categoryName,
                        amount: formatCurrency(cat.total),
                        progress: cat.percentage / 100,
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),

        // ── Download PDF button ───────────────────────────────────────
        _DownloadPdfButton(
          isLoading: state.isExportLoading,
          onTap: onDownloadPdf,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showMonthYearPicker(BuildContext context, WidgetRef ref, int initialMonth, int initialYear) {
    int selectedMonth = initialMonth;
    int selectedYear = initialYear;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF141E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Pilih Bulan & Tahun', style: TextStyle(color: Colors.white)),
              content: Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      value: selectedMonth,
                      dropdownColor: const Color(0xFF1F2E46),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(kMonthNames[index]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMonth = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<int>(
                      value: selectedYear,
                      dropdownColor: const Color(0xFF1F2E46),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: List.generate(10, (index) {
                        final y = DateTime.now().year - 5 + index;
                        return DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedYear = val);
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(laporanProvider.notifier).changeMonthYear(selectedMonth, selectedYear);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5A8)),
                  child: const Text('Pilih', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Month navigator ───────────────────────────────────────────────────────────

class _MonthNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTapLabel;

  const _MonthNavigator({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onTapLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTapLabel,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5A8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Pie chart + legend section ────────────────────────────────────────────────

class _BulananPieSection extends StatelessWidget {
  final List<AnalyticsCategoryModel> categories;

  const _BulananPieSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: categories.map((cat) {
                return PieChartSectionData(
                  value: cat.total,
                  color: getCategoryColor(cat.categoryId, cat.categoryName),
                  radius: 65,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LaporanLegendItem(
                  color: getCategoryColor(cat.categoryId, cat.categoryName),
                  label:
                      '${cat.categoryName} ${cat.percentage.toInt()}%',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Download PDF button ───────────────────────────────────────────────────────

class _DownloadPdfButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _DownloadPdfButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black),
              )
            : const Icon(Icons.picture_as_pdf,
                color: Colors.black, size: 20),
        label: Text(
          isLoading
              ? 'Sedang Mengekspor...'
              : 'Unduh Laporan PDF',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5A8),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
