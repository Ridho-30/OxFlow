import 'dart:async';
import 'package:flutter/material.dart';
import 'ocr_validation_screen.dart';

class OcrProcessingScreen extends StatefulWidget {
  final String imagePath;
  const OcrProcessingScreen({super.key, required this.imagePath});

  @override
  State<OcrProcessingScreen> createState() => _OcrProcessingScreenState();
}

class _OcrProcessingScreenState extends State<OcrProcessingScreen> {
  double _analisisProgress = 0.0;
  double _ekstrakProgress = 0.0;
  String _statusMessage = 'Menganalisis gambar...';
  Timer? _timer;
  int _secondsRemaining = 6;

  @override
  void initState() {
    super.initState();
    _startSimulatedOcr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSimulatedOcr() {
    const period = Duration(milliseconds: 100);
    _timer = Timer.periodic(period, (timer) {
      if (!mounted) return;

      setState(() {
        if (_analisisProgress < 1.0) {
          _analisisProgress += 0.033; // ~3 seconds to complete analysis
          if (_analisisProgress >= 1.0) {
            _analisisProgress = 1.0;
            _statusMessage = 'Mengekstrak data transaksi...';
          }
        } else if (_ekstrakProgress < 1.0) {
          _ekstrakProgress += 0.033; // ~3 seconds to complete extraction
          if (_ekstrakProgress >= 1.0) {
            _ekstrakProgress = 1.0;
            _statusMessage = 'Pemrosesan selesai!';
          }
        }

        // Calculate estimated seconds remaining
        final totalProgress = (_analisisProgress + _ekstrakProgress) / 2.0;
        _secondsRemaining = (6 * (1.0 - totalProgress)).ceil();

        if (_analisisProgress >= 1.0 && _ekstrakProgress >= 1.0) {
          _timer?.cancel();
          // Navigate to OcrValidationScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OcrValidationScreen(imagePath: widget.imagePath),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Loading Spinner Accent
              const Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title Header
              const Text(
                'Memproses Gambar...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusMessage,
                style: const TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),

              // Analisis Progress Bar
              _buildProgressRow('Analisis', _analisisProgress),
              const SizedBox(height: 20),

              // Ekstrak Data Progress Bar
              _buildProgressRow('Ekstrak Data', _ekstrakProgress),
              const SizedBox(height: 32),

              // Estimated time remaining
              Text(
                'Estimasi waktu tersisa: $_secondsRemaining detik',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context); // Go back to preview
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1F2E46)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(String title, double progress) {
    final int percentage = (progress * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(color: Color(0xFF00E5A8), fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color(0xFF141E2E),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
          ),
        ),
      ],
    );
  }
}
