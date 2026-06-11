import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Analisis Pengeluaran',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildCategoryCard(),

            const SizedBox(height: 25),

            const Text(
              'Pengeluaran Mingguan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildBarChart(),

            const SizedBox(height: 25),

            _buildTopCategoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(
            'Pengeluaran Berdasarkan Kategori',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,

                sections: [

                  PieChartSectionData(
                    value: 40,
                    title: '40%',
                    color: Colors.greenAccent,
                  ),

                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: Colors.blueAccent,
                  ),

                  PieChartSectionData(
                    value: 20,
                    title: '20%',
                    color: Colors.orangeAccent,
                  ),

                  PieChartSectionData(
                    value: 15,
                    title: '15%',
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(show: false),

          barGroups: [

            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 200,
                  color: Colors.greenAccent,
                ),
              ],
            ),

            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 300,
                  color: Colors.greenAccent,
                ),
              ],
            ),

            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 250,
                  color: Colors.greenAccent,
                ),
              ],
            ),

            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 400,
                  color: Colors.greenAccent,
                ),
              ],
            ),

            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 350,
                  color: Colors.greenAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            'Kategori Pengeluaran Tertinggi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 15),

          Text(
            'Makanan & Minuman',
            style: TextStyle(
              color: Color(0xFF00E5A8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Rp 500.000',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}