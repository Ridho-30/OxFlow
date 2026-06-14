import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/month_year_picker_dialog.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _selectedPeriod = 'Harian';
  bool _isDownloadingPDF = false;

  // Selected date states
  DateTime _currentDate = DateTime(2026, 6, 13);
  // int _currentWeekOffset = 0; // 0 is current week, -1 prev week, etc.
  // int _currentMonthOffset = 0; // 0 is June 2026, -1 May 2026, etc.

  // Expanded card state for weekly view
  int _expandedDayIndex = -1; // -1 means none expanded

  // Mock data for transactions
  final List<Map<String, dynamic>> _mockTransactions = [
    {
      'id': '1',
      'title': 'Indomaret',
      'category': 'Makanan',
      'amount': -45000.0,
      'time': '14:30',
      'date': '2026-06-13',
      'desc': 'Belanja Cemilan & Roti',
      'qty': 3,
    },
    {
      'id': '2',
      'title': 'Gojek / Grab',
      'category': 'Transportasi',
      'amount': -28000.0,
      'time': '08:15',
      'date': '2026-06-13',
      'desc': 'Perjalanan ke Kampus',
      'qty': 1,
    },
    {
      'id': '3',
      'title': 'Pemasukan Bulanan',
      'category': 'Gaji',
      'amount': 5000000.0,
      'time': '10:00',
      'date': '2026-06-13',
      'desc': 'Gaji bulanan',
      'qty': 1,
    },
    {
      'id': '4',
      'title': 'Kopi Kenangan',
      'category': 'Makanan',
      'amount': -32000.0,
      'time': '16:00',
      'date': '2026-06-13',
      'desc': 'Kopi susu gula aren',
      'qty': 1,
    },
    {
      'id': '5',
      'title': 'Bensin Pertamina',
      'category': 'Transportasi',
      'amount': -50000.0,
      'time': '11:20',
      'date': '2026-06-12',
      'desc': 'Isi Pertamax',
      'qty': 1,
    },
  ];

  void _downloadPDF() {
    showDialog(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        initialMonth: _currentDate.month,
        initialYear: _currentDate.year,
        onConfirm: (month, year) {
          _executeDownload(month, year);
        },
      ),
    );
  }

  void _executeDownload(int month, int year) {
    setState(() {
      _isDownloadingPDF = true;
    });

    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final String selectedMonthName = months[month - 1];

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isDownloadingPDF = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan $selectedMonthName $year berhasil diunduh'),
          backgroundColor: const Color(0xFF0C2B29),
        ),
      );
    });
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final double amount = tx['amount'];
        final bool isExpense = amount < 0;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Transaksi',
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
              _buildDetailRow('Tanggal', tx['date']),
              _buildDetailRow('Waktu', tx['time']),
              _buildDetailRow('Kategori', tx['category']),
              _buildDetailRow('Nama Toko', tx['title']),
              _buildDetailRow('Deskripsi', tx['desc'] ?? '-'),
              _buildDetailRow('Jumlah Item', '${tx['qty']}'),
              _buildDetailRow(
                'Total',
                'Rp ${amount.abs().toInt()}',
                valueColor: isExpense
                    ? Colors.redAccent
                    : const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit transaksi (Simulasi)'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1F2E46)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transaksi dihapus'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          _isDownloadingPDF
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF00E5A8),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.download, color: Color(0xFF00E5A8)),
                  tooltip: 'Unduh laporan PDF',
                  onPressed: _downloadPDF,
                ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Period selector tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: _buildSegmentedControl(),
            ),

            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    if (_selectedPeriod == 'Harian') _buildHarianTab(),
                    if (_selectedPeriod == 'Mingguan') _buildMingguanTab(),
                    if (_selectedPeriod == 'Bulanan') _buildBulananTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegmentItem('Harian'),
          _buildSegmentItem('Mingguan'),
          _buildSegmentItem('Bulanan'),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String title) {
    final bool isSelected = _selectedPeriod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5A8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF0B1220)
                    : const Color(0xFF8A99AD),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HARIAN TAB VIEW ====================
  Widget _buildHarianTab() {
    // Format date Indonesian
    final String formattedDate =
        "Sabtu, ${_currentDate.day} Juni ${_currentDate.year}";

    // Filter transactions for this date
    final String dateString =
        "${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}";
    final dayTx = _mockTransactions
        .where((t) => t['date'] == dateString)
        .toList();

    double expenseSum = 0.0;
    double incomeSum = 0.0;
    for (var tx in dayTx) {
      if (tx['amount'] < 0) {
        expenseSum += tx['amount'].abs();
      } else {
        incomeSum += tx['amount'];
      }
    }
    double netBalance = incomeSum - expenseSum;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF00E5A8)),
              onPressed: () {
                setState(() {
                  _currentDate = _currentDate.subtract(const Duration(days: 1));
                });
              },
            ),
            Text(
              formattedDate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00E5A8)),
              onPressed: () {
                setState(() {
                  _currentDate = _currentDate.add(const Duration(days: 1));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2E46)),
          ),
          child: Column(
            children: [
              _buildSummaryField(
                'Total Pengeluaran',
                'Rp ${expenseSum.toInt()}',
                Colors.redAccent,
              ),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Total Pemasukan',
                'Rp ${incomeSum.toInt()}',
                const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF1F2E46)),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Saldo Bersih',
                'Rp ${netBalance.toInt()}',
                netBalance >= 0 ? const Color(0xFF00E5A8) : Colors.redAccent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Transaction list
        const Text(
          'TRANSAKSI HARI INI',
          style: TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        if (dayTx.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Tidak ada transaksi pada tanggal ini',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayTx.length,
            itemBuilder: (context, index) {
              final tx = dayTx[index];
              final double amount = tx['amount'];
              final bool isExpense = amount < 0;

              IconData categoryIcon = Icons.fastfood;
              if (tx['category'] == 'Transportasi') {
                categoryIcon = Icons.directions_car;
              } else if (tx['category'] == 'Gaji') {
                categoryIcon = Icons.monetization_on;
              }

              return Card(
                color: const Color(0xFF141E2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF1F2E46)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => _showTransactionDetails(tx),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0B1220),
                    child: Icon(
                      categoryIcon,
                      color: const Color(0xFF00E5A8),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tx['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${tx['category']} • ${tx['time']}",
                    style: const TextStyle(
                      color: Color(0xFF8A99AD),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    isExpense
                        ? '-Rp ${amount.abs().toInt()}'
                        : '+Rp ${amount.toInt()}',
                    style: TextStyle(
                      color: isExpense
                          ? Colors.redAccent
                          : const Color(0xFF00E5A8),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSummaryField(String label, String val, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
        ),
        Text(
          val,
          style: TextStyle(
            color: valColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==================== MINGGUAN TAB VIEW ====================
  Widget _buildMingguanTab() {
    // Current range
    final String weekRange = "09 Juni - 15 Juni 2026";

    // Mock weekly daily breakdown
    final List<Map<String, dynamic>> dailyBreakdown = [
      {
        'day': 'Senin, 09 Juni',
        'spent': 125000.0,
        'txs': ['Makan siang Rp 45.000', 'Gojek Rp 80.000'],
      },
      {
        'day': 'Selasa, 10 Juni',
        'spent': 180000.0,
        'txs': ['Supermarket Rp 150.000', 'Parkir Rp 30.000'],
      },
      {
        'day': 'Rabu, 11 Juni',
        'spent': 95000.0,
        'txs': ['Kopi Rp 35.000', 'Gojek Rp 60.000'],
      },
      {
        'day': 'Kamis, 12 Juni',
        'spent': 220000.0,
        'txs': ['Bensin Rp 50.000', 'Makan malam Rp 170.000'],
      },
      {
        'day': 'Jumat, 13 Juni',
        'spent': 155000.0,
        'txs': ['Cemilan Rp 45.000', 'Kopi Rp 32.000', 'Grab Rp 28.000'],
      },
      {
        'day': 'Sabtu, 14 Juni',
        'spent': 310000.0,
        'txs': ['Bioskop & Popcorn Rp 110.000', 'Belanja Baju Rp 200.000'],
      },
      {
        'day': 'Minggu, 15 Juni',
        'spent': 98000.0,
        'txs': ['Sarapan Rp 38.000', 'Supermarket Rp 60.000'],
      },
    ];

    double totalWeeklySpent = dailyBreakdown.fold(
      0.0,
      (sum, item) => sum + item['spent'],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week range Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF00E5A8)),
              onPressed: () {},
            ),
            Text(
              weekRange,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00E5A8)),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekly summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2E46)),
          ),
          child: Column(
            children: [
              _buildSummaryField(
                'Total Pengeluaran',
                'Rp ${totalWeeklySpent.toInt()}',
                Colors.redAccent,
              ),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Total Pemasukan',
                'Rp 5.000.000',
                const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Rata-rata Harian',
                'Rp ${(totalWeeklySpent / 7).toInt()}',
                Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Weekly spending trend bar chart
        const Text(
          'TREN PENGELUARAN MINGGUAN',
          style: TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2E46)),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 350000,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const days = [
                        'Sen',
                        'Sel',
                        'Rab',
                        'Kam',
                        'Jum',
                        'Sab',
                        'Min',
                      ];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: Color(0xFF8A99AD),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                _buildBarGroup(0, 125000.0),
                _buildBarGroup(1, 180000.0),
                _buildBarGroup(2, 95000.0),
                _buildBarGroup(3, 220000.0),
                _buildBarGroup(4, 155000.0),
                _buildBarGroup(5, 310000.0),
                _buildBarGroup(6, 98000.0),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Breakdown daily list (with expandable details)
        const Text(
          'RINCIAN PENGELUARAN HARIAN (Tap untuk detail)',
          style: TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dailyBreakdown.length,
          itemBuilder: (context, index) {
            final dayItem = dailyBreakdown[index];
            final bool isExpanded = _expandedDayIndex == index;

            return Card(
              color: const Color(0xFF141E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF1F2E46)),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: PageStorageKey<int>(index),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedDayIndex = expanded ? index : -1;
                    });
                  },
                  title: Text(
                    dayItem['day'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Text(
                    'Rp ${dayItem['spent'].toInt()}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0E1724),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (dayItem['txs'] as List<String>).map((
                          txText,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.subdirectory_arrow_right,
                                  size: 14,
                                  color: Color(0xFF00E5A8),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  txText,
                                  style: const TextStyle(
                                    color: Color(0xFF8A99AD),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Category breakdown
        const Text(
          'KATEGORI TERBESAR MINGGU INI',
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
          child: Column(
            children: [
              _buildCategorySummaryRow(
                'Makanan',
                450000.0,
                38,
                const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 12),
              _buildCategorySummaryRow(
                'Transportasi',
                280000.0,
                24,
                const Color(0xFF2F80ED),
              ),
              const SizedBox(height: 12),
              _buildCategorySummaryRow(
                'Entertainment',
                200000.0,
                17,
                const Color(0xFFF2C94C),
              ),
              const SizedBox(height: 12),
              _buildCategorySummaryRow(
                'Lainnya',
                233000.0,
                21,
                const Color(0xFFEB5757),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double spent) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: spent,
          color: const Color(0xFF00E5A8),
          width: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildCategorySummaryRow(
    String category,
    double amount,
    int pct,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              category,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'Rp ${amount.toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($pct%)',
              style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== BULANAN TAB VIEW ====================
  Widget _buildBulananTab() {
    final String currentMonth = "Juni 2026";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF00E5A8)),
              onPressed: () {},
            ),
            Text(
              currentMonth,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF00E5A8)),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Monthly Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141E2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F2E46)),
          ),
          child: Column(
            children: [
              _buildSummaryField(
                'Total Pengeluaran',
                'Rp 3.650.000',
                Colors.redAccent,
              ),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Total Pemasukan',
                'Rp 5.000.000',
                const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Saldo Bersih',
                'Rp 1.350.000',
                const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 10),
              _buildSummaryField(
                'Rata-rata Harian',
                'Rp 121.666',
                Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Distribution Pie Chart
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
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 0,
                  sections: [
                    PieChartSectionData(
                      value: 42,
                      color: const Color(0xFF00E5A8),
                      radius: 60,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 30,
                      color: const Color(0xFF2F80ED),
                      radius: 60,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 18,
                      color: const Color(0xFFF2C94C),
                      radius: 60,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: 10,
                      color: const Color(0xFFEB5757),
                      radius: 60,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(const Color(0xFF00E5A8), 'Makanan 42%'),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xFF2F80ED), 'Transport 30%'),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xFFF2C94C), 'Belanja 18%'),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xFFEB5757), 'Lainnya 10%'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Category Progress breakdown list
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
          child: Column(
            children: [
              _buildCategoryProgressField(
                'Makanan',
                'Rp 1.200.000',
                0.42,
                const Color(0xFF00E5A8),
              ),
              const SizedBox(height: 16),
              _buildCategoryProgressField(
                'Transportasi',
                'Rp 850.000',
                0.30,
                const Color(0xFF2F80ED),
              ),
              const SizedBox(height: 16),
              _buildCategoryProgressField(
                'Belanja',
                'Rp 500.000',
                0.18,
                const Color(0xFFF2C94C),
              ),
              const SizedBox(height: 16),
              _buildCategoryProgressField(
                'Lainnya',
                'Rp 300.000',
                0.10,
                const Color(0xFFEB5757),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Weekly Breakdown
        const Text(
          'BREAKDOWN MINGGUAN',
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
          child: Column(
            children: [
              _buildWeeklyBreakdownRow('Minggu 1 (02-08 Juni)', 'Rp 950.000'),
              const Divider(color: Color(0xFF1F2E46), height: 24),
              _buildWeeklyBreakdownRow('Minggu 2 (09-15 Juni)', 'Rp 1.100.000'),
              const Divider(color: Color(0xFF1F2E46), height: 24),
              _buildWeeklyBreakdownRow('Minggu 3 (16-22 Juni)', 'Rp 850.000'),
              const Divider(color: Color(0xFF1F2E46), height: 24),
              _buildWeeklyBreakdownRow('Minggu 4 (23-30 Juni)', 'Rp 750.000'),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryProgressField(
    String label,
    String amount,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFF0B1220),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBreakdownRow(String weekLabel, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          weekLabel,
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
