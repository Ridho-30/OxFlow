import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141E2E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1F2E46), width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, color: Color(0xFF8A99AD)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Atur Anggaran Card
              _buildSetBudgetCard(),
              const SizedBox(height: 20),

              // Spending Progress Card
              _buildSpendingProgressCard(),
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

              // Detail per Category Section
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
              _buildCategoryDetailItem(
                percentage: '40%',
                categoryName: 'Makanan',
                amount: 'Rp 500.000',
              ),
              const Divider(color: Color(0xFF1F2E46), height: 1),
              _buildCategoryDetailItem(
                percentage: '25%',
                categoryName: 'Transportasi',
                amount: 'Rp 312.500',
              ),
              const Divider(color: Color(0xFF1F2E46), height: 1),
              _buildCategoryDetailItem(
                percentage: '15%',
                categoryName: 'Belanja',
                amount: 'Rp 187.500',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetBudgetCard() {
    return Container(
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
              children: const [
                Text(
                  'Atur anggaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Income: Rp 5.000.000 • Batas: Rp 2.000.000',
                  style: TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 12,
                  ),
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
    );
  }

  Widget _buildSpendingProgressCard() {
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
            children: const [
              Text(
                'Terpakai',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 14,
                ),
              ),
              Text(
                '62%',
                style: TextStyle(
                  color: Color(0xFFF2C94C),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              text: 'Rp 1.250.000 ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'dari Rp 2.000.000',
                  style: TextStyle(
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
            child: const LinearProgressIndicator(
              value: 0.62,
              minHeight: 8,
              backgroundColor: Color(0xFF0B1220),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2C94C)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF2C94C),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Mendekati batas anggaran',
                style: TextStyle(
                  color: Color(0xFFF2C94C),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChartSection() {
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
                  value: 40,
                  color: const Color(0xFF00E5A8), // Makanan
                  radius: 65,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 25,
                  color: const Color(0xFF2F80ED), // Transport
                  radius: 65,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 15,
                  color: const Color(0xFFF2C94C), // Belanja
                  radius: 65,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 20,
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
              _buildLegendItem(const Color(0xFF00E5A8), 'Makanan 40%'),
              const SizedBox(height: 12),
              _buildLegendItem(const Color(0xFF2F80ED), 'Transport 25%'),
              const SizedBox(height: 12),
              _buildLegendItem(const Color(0xFFF2C94C), 'Belanja 15%'),
              const SizedBox(height: 12),
              _buildLegendItem(const Color(0xFFEB5757), 'Lainnya 20%'),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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

  Widget _buildCategoryDetailItem({
    required String percentage,
    required String categoryName,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                percentage,
                style: const TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFFEB5757),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}