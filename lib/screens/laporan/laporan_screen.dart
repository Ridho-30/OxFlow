import 'package:flutter/material.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _selectedPeriod = 'Harian';

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
              // Header navigation (Month Selector)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF00E5A8),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Juni 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF00E5A8),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Segmented Control / Toggle Pill
              _buildSegmentedControl(),
              const SizedBox(height: 28),

              // Summary Section (Pemasukan, Pengeluaran, Saldo)
              _buildSummarySection(),
              const SizedBox(height: 32),

              // Grouped Transaction List
              // Date Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '13 Jun 2026 • Sabtu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rp 105.000',
                    style: TextStyle(
                      color: Color(0xFFFF4D4D),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of transaction items
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
              const SizedBox(height: 32),

              // Unduh PDF Button
              _buildDownloadPDFButton(),
            ],
          ),
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

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        children: [
          _buildSummaryRow('Pemasukan', '5.000.000', const Color(0xFF00E5A8)),
          const SizedBox(height: 16),
          _buildSummaryRow('Pengeluaran', '1.250.000', const Color(0xFFFF4D4D)),
          const SizedBox(height: 16),
          _buildSummaryRow('Saldo', '3.750.000', Colors.white),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color amountColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A99AD),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
                style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 12),
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

  Widget _buildDownloadPDFButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0C2B29),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00E5A8), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.file_download_outlined,
              color: Color(0xFF00E5A8),
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Unduh laporan PDF bulan ini',
              style: TextStyle(
                color: Color(0xFF00E5A8),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
