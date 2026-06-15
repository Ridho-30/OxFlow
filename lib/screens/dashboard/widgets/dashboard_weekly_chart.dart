// lib/screens/dashboard/widgets/dashboard_weekly_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/analytics/dashboard_model.dart';

// Shared formatter — created once, not on every build.
final _kFmt = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

/// Weekly bar chart section for the Dashboard.
/// Extracted from [DashboardScreen._buildWeeklyChartSection] +
/// [DashboardScreen._makeBarGroup].
class DashboardWeeklyChart extends StatelessWidget {
  final List<DashboardWeeklyChartItemModel> weeklyChart;

  const DashboardWeeklyChart({super.key, required this.weeklyChart});

  @override
  Widget build(BuildContext context) {
    if (weeklyChart.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF141E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F2E46)),
        ),
        child: const Text(
          'Belum ada data pengeluaran minggu ini',
          style: TextStyle(color: Color(0xFF8A99AD)),
        ),
      );
    }

    double maxSpent = weeklyChart.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    if (maxSpent <= 0) maxSpent = 1000.0;
    final double maxY = maxSpent * 1.15;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipColor: (_) => const Color(0xFF141E2E),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  _kFmt.format(rod.toY),
                  const TextStyle(
                    color: Color(0xFF00E5A8),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklyChart.length) {
                    return const SizedBox.shrink();
                  }
                  String label = weeklyChart[index].day;
                  if (label.length > 3) label = label.substring(0, 3);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF8A99AD),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(weeklyChart.length, (index) {
            return _makeBarGroup(index, weeklyChart[index].total, maxY);
          }),
        ),
      ),
    );
  }

  static BarChartGroupData _makeBarGroup(int x, double y, double maxY) {
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
            toY: maxY,
            color: const Color(0xFF141E2E),
          ),
        ),
      ],
    );
  }
}
