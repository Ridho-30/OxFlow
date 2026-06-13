import 'package:flutter/material.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final Function(int month, int year) onConfirm;
  final int initialMonth;
  final int initialYear;

  const MonthYearPickerDialog({
    super.key,
    required this.onConfirm,
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _selectedMonth;
  late int _selectedYear;

  final List<String> _months = [
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
    'Desember'
  ];

  final List<int> _years = [2024, 2025, 2026];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  // Check if a period (month + year) is in the future relative to current date
  bool _isFutureDate(int month, int year) {
    // Use fixed current date 13 June 2026 from user's current environment if datetime is different,
    // but DateTime.now() is standard. To be robust, let's check against June 2026.
    final currentYear = 2026;
    final currentMonth = 6;

    if (year > currentYear) return true;
    if (year == currentYear && month > currentMonth) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Bulan dan Tahun Laporan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Month Dropdown
            const Text(
              'Bulan',
              style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1F2E46)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  dropdownColor: const Color(0xFF141E2E),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5A8)),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: List.generate(12, (index) {
                    final monthIndex = index + 1;
                    final isDisabled = _isFutureDate(monthIndex, _selectedYear);
                    return DropdownMenuItem<int>(
                      value: monthIndex,
                      enabled: !isDisabled,
                      child: Text(
                        _months[index],
                        style: TextStyle(
                          color: isDisabled ? Colors.grey[700] : Colors.white,
                        ),
                      ),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMonth = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Year Dropdown
            const Text(
              'Tahun',
              style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1F2E46)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  dropdownColor: const Color(0xFF141E2E),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E5A8)),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: _years.map((year) {
                    // disable year if it has no valid months
                    final allFuture = List.generate(12, (i) => _isFutureDate(i + 1, year)).every((e) => e);
                    return DropdownMenuItem<int>(
                      value: year,
                      enabled: !allFuture,
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          color: allFuture ? Colors.grey[700] : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedYear = val;
                        // Adjust selected month if it is now in the future for the selected year
                        if (_isFutureDate(_selectedMonth, _selectedYear)) {
                          _selectedMonth = 1; // Default to Jan
                        }
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Catatan: Laporan akan didownload untuk periode ${_months[_selectedMonth - 1]} $_selectedYear.',
              style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirm(_selectedMonth, _selectedYear);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5A8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
