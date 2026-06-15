import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import '../../providers/laporan_provider.dart';
import '../../widgets/month_year_picker_dialog.dart';
import 'widgets/laporan_harian_tab.dart';
import 'widgets/laporan_mingguan_tab.dart';
import 'widgets/laporan_bulanan_tab.dart';

class LaporanScreen extends ConsumerStatefulWidget {
  const LaporanScreen({super.key});

  @override
  ConsumerState<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends ConsumerState<LaporanScreen> {
  // Triggers PDF Export & download dialog
  void _downloadPDF() {
    final state = ref.read(laporanProvider);
    showDialog(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        initialMonth: state.selectedMonth,
        initialYear: state.selectedYear,
        onConfirm: (month, year) {
          _executeDownload(month, year);
        },
      ),
    );
  }

  // Executes actual export call and browser launch
  Future<void> _executeDownload(int month, int year) async {
    final notifier = ref.read(laporanProvider.notifier);

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

    try {
      final fileUrl = await notifier.exportReportPdf(month, year);

      if (!mounted) return;
      if (fileUrl != null && fileUrl.isNotEmpty) {
        // Prepare target directories
        Directory? targetDir;
        bool isAppDocDir = false;

        if (Platform.isAndroid) {
          // Android Download directory
          targetDir = Directory('/storage/emulated/0/Download');
          if (!await targetDir.exists()) {
            targetDir = await getExternalStorageDirectory();
          }
        } else if (Platform.isIOS) {
          // iOS Document directory
          targetDir = await getApplicationDocumentsDirectory();
          isAppDocDir = true;
        } else {
          targetDir = await getDownloadsDirectory();
        }

        // Check/request permission for public storage on Android 9 and below
        if (Platform.isAndroid &&
            targetDir != null &&
            targetDir.path.startsWith('/storage/emulated/0')) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            // Fallback to application documents if permission denied
            targetDir = await getApplicationDocumentsDirectory();
            isAppDocDir = true;
          }
        }

        if (targetDir == null) {
          targetDir = await getApplicationDocumentsDirectory();
          isAppDocDir = true;
        }

        final fileName = 'OxFlow_Laporan_${selectedMonthName}_$year.pdf';
        String savePath = '${targetDir.path}/$fileName';

        // Perform actual download using Dio
        final dio = Dio();
        try {
          await dio.download(fileUrl, savePath);
        } catch (e) {
          // If public storage download fails, try fallback to app documents directory
          targetDir = await getApplicationDocumentsDirectory();
          isAppDocDir = true;
          savePath = '${targetDir.path}/$fileName';
          await dio.download(fileUrl, savePath);
        }

        if (!mounted) return;

        final displayPath = isAppDocDir
            ? 'Dokumen Aplikasi'
            : 'Folder Downloads';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengunduh Laporan ke $displayPath'),
            backgroundColor: const Color(0xFF0C2B29),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'BUKA',
              textColor: const Color(0xFF00E5A8),
              onPressed: () async {
                final result = await OpenFilex.open(savePath);
                if (result.type != ResultType.done && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tidak dapat membuka file: ${result.message}',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengekspor laporan PDF (URL kosong)'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh PDF: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(laporanProvider);

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
          state.isExportLoading
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
              child: _buildSegmentedControl(state.selectedPeriod),
            ),

            // Main scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.read(laporanProvider.notifier).loadCurrentPeriodData();
                },
                color: const Color(0xFF00E5A8),
                backgroundColor: const Color(0xFF141E2E),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      if (state.selectedPeriod == 'Harian')
                        const LaporanHarianTab(),
                      if (state.selectedPeriod == 'Mingguan')
                        const LaporanMingguanTab(),
                      if (state.selectedPeriod == 'Bulanan')
                        LaporanBulananTab(onDownloadPdf: _downloadPDF),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(String selectedPeriod) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSegmentItem('Harian', selectedPeriod),
          _buildSegmentItem('Mingguan', selectedPeriod),
          _buildSegmentItem('Bulanan', selectedPeriod),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(String title, String selectedPeriod) {
    final bool isSelected = selectedPeriod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(laporanProvider.notifier).changePeriod(title);
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
}
