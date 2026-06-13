import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              // Header
              const Text(
                'Beranda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Juni 2026',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Total Expense Card
              _buildTotalExpenseCard(),
              const SizedBox(height: 16),

              // Sisa Anggaran & Status row
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Sisa anggaran',
                      value: 'Rp 750.000',
                      valueColor: const Color(0xFF00E5A8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Status',
                      value: 'Aman',
                      valueColor: const Color(0xFF00E5A8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Weekly Expense Section
              const Text(
                'PENGELUARAN MINGGUAN',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildWeeklyBarChart(),
              const SizedBox(height: 32),

              // Recent Transactions Section
              const Text(
                'TRANSAKSI TERBARU',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Transaction List
              _buildTransactionItem(
                category: 'Makanan',
                title: 'Indomaret',
                amount: '-Rp 45.000',
              ),
              const Divider(color: Color(0xFF1F2E46), height: 1),
              _buildTransactionItem(
                category: 'Transportasi',
                title: 'Grab',
                amount: '-Rp 28.000',
              ),
              const Divider(color: Color(0xFF1F2E46), height: 1),
              _buildTransactionItem(
                category: 'Makanan',
                title: 'Kopi Kenangan',
                amount: '-Rp 32.000',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalExpenseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Total pengeluaran bulan ini',
            style: TextStyle(
              color: Color(0xFF8A99AD),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rp 1.250.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A99AD),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Color(0xFF8A99AD),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Sen';
                      break;
                    case 1:
                      text = 'Sel';
                      break;
                    case 2:
                      text = 'Rab';
                      break;
                    case 3:
                      text = 'Kam';
                      break;
                    case 4:
                      text = 'Jum';
                      break;
                    case 5:
                      text = 'Sab';
                      break;
                    case 6:
                      text = 'Min';
                      break;
                    default:
                      text = '';
                      break;
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeBarGroup(0, 45),
            _makeBarGroup(1, 30),
            _makeBarGroup(2, 65),
            _makeBarGroup(3, 20),
            _makeBarGroup(4, 85),
            _makeBarGroup(5, 55),
            _makeBarGroup(6, 40),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF00E5A8),
          width: 14,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: const Color(0xFF141E2E),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String category,
    required String title,
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
                category,
                style: const TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
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
              color: Color(0xFFFF4D4D),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}