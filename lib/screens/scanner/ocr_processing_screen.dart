// lib/screens/scanner/ocr_processing_screen.dart
//
// Alur:
//  1. ML Kit Text Recognition → raw text
//  2. POST /api/ocr/parse (backend Gemini LLM) → ParsedReceipt
//  3. Navigate ke OcrValidationScreen dengan data terisi

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../services/ocr/ocr_service.dart';
import '../../services/ocr/receipt_parser.dart';
import 'ocr_validation_screen.dart';
import 'input_manual_screen.dart';

class OcrProcessingScreen extends StatefulWidget {
  final String imagePath;
  const OcrProcessingScreen({super.key, required this.imagePath});

  @override
  State<OcrProcessingScreen> createState() => _OcrProcessingScreenState();
}

class _OcrProcessingScreenState extends State<OcrProcessingScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  _Stage _stage = _Stage.mlKit;   // Current processing stage
  double _progressMlKit = 0.0;
  double _progressBackend = 0.0;
  bool _hasError = false;

  Timer? _mlKitTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startMlKitProgressAnimation();
    _runPipeline();
  }

  @override
  void dispose() {
    _mlKitTimer?.cancel();
    super.dispose();
  }

  // ── Pipeline ───────────────────────────────────────────────────────────────

  Future<void> _runPipeline() async {
    // ── STEP 1: ML Kit local text recognition ───────────────────────────────
    String rawText = '';
    try {
      if (widget.imagePath.startsWith('assets/')) {
        // Mock for testing with asset images
        await Future.delayed(const Duration(milliseconds: 1200));
        rawText = _mockReceiptText();
      } else {
        final inputImage = InputImage.fromFilePath(widget.imagePath);
        final recognizer =
            TextRecognizer(script: TextRecognitionScript.latin);
        final recognized = await recognizer.processImage(inputImage);
        await recognizer.close();

        rawText = recognized.text;
        debugPrint('[OcrProcessing] ML Kit raw text (${rawText.length} chars):');
        debugPrint(rawText);
      }

      if (rawText.trim().length < 10) {
        _showError(
          'Teks di struk tidak terbaca. Foto ulang dengan cahaya yang cukup.',
        );
        return;
      }

      // Animate ML Kit progress to 100%
      if (mounted) {
        setState(() {
          _progressMlKit = 1.0;
          _stage = _Stage.backend;
        });
      }
      _mlKitTimer?.cancel();
    } catch (e) {
      _showError('Gagal memproses gambar: $e');
      return;
    }

    // ── STEP 2: Backend Gemini LLM parsing ──────────────────────────────────
    _startBackendProgressAnimation();

    ParsedReceipt result;
    try {
      result = await OcrService.parseViaBackend(rawText);
    } on OcrServiceException catch (e) {
      _showError(e.message, isNetwork: e.isNetworkError);
      return;
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
      return;
    }

    // ── STEP 3: Navigate ─────────────────────────────────────────────────────
    if (!mounted) return;
    setState(() {
      _progressBackend = 1.0;
    });

    // Brief pause so the user sees 100% before navigating
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OcrValidationScreen(
          imagePath: widget.imagePath,
          parsedReceipt: result,
        ),
      ),
    );
  }

  // ── Error handling ─────────────────────────────────────────────────────────

  void _showError(String message, {bool isNetwork = false}) {
    _mlKitTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _hasError = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              color: Colors.orangeAccent,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Gagal Memproses Struk',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Kembali ke scanner
            },
            child: const Text('Foto Ulang',
                style: TextStyle(color: Color(0xFF8A99AD))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const InputManualScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5A8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Input Manual',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Progress animations ────────────────────────────────────────────────────

  void _startMlKitProgressAnimation() {
    const period = Duration(milliseconds: 80);
    _mlKitTimer = Timer.periodic(period, (t) {
      if (!mounted || _hasError) {
        t.cancel();
        return;
      }
      setState(() {
        if (_progressMlKit < 0.9) {
          // Animate up to 90%, the final 10% is set when ML Kit actually finishes
          _progressMlKit = (_progressMlKit + 0.03).clamp(0.0, 0.9);
        }
      });
    });
  }

  Timer? _backendTimer;
  void _startBackendProgressAnimation() {
    const period = Duration(milliseconds: 120);
    _backendTimer = Timer.periodic(period, (t) {
      if (!mounted || _hasError) {
        t.cancel();
        return;
      }
      setState(() {
        if (_progressBackend < 0.92) {
          // Slower animation for backend LLM call (can take ~10-30s)
          _progressBackend = (_progressBackend + 0.015).clamp(0.0, 0.92);
        }
      });
    });
  }

  // ── Mock data (for asset image testing) ───────────────────────────────────

  String _mockReceiptText() => '''
QRIS BANK MANDIRI
JO CAFE
Jl. Bondoyudo No. 31, Patrang
Telp. +6282332656497
Meja 532 - 1 - Code TR : TR73260523045717 - 17:04 WIB
NO MENU HARGA QTY JUMLAH
1 LEMONADE ICE 15.000 1 Rp. 15.000
2 CHICKEN CURY 25.000 2 Rp. 50.000
3 ES CINCAU 10.000 1 Rp. 10.000
PB1 10 % Rp. 7.500
Total Rp. 82.500
Tagihan : Rp. 82.500
Bayar : Rp. 82.500
Kembalian : Rp. 0
''';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String stageLabel = _stage == _Stage.mlKit
        ? 'Menganalisis gambar dengan ML Kit...'
        : 'Mengekstrak data struk via AI...';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Spinner
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                'Memproses Struk...',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                stageLabel,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Color(0xFF8A99AD), fontSize: 14),
              ),
              const SizedBox(height: 48),

              // Stage 1: ML Kit
              _buildProgressRow(
                icon: Icons.image_search_rounded,
                title: 'Membaca Teks (ML Kit)',
                progress: _progressMlKit,
                done: _progressMlKit >= 1.0,
              ),
              const SizedBox(height: 20),

              // Stage 2: Backend AI
              _buildProgressRow(
                icon: Icons.auto_awesome_rounded,
                title: 'Parsing via AI Backend',
                progress: _progressBackend,
                done: _progressBackend >= 1.0,
              ),
              const SizedBox(height: 32),

              // Info note
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141E2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1F2E46)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline,
                        color: Color(0xFF00E5A8), size: 16),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI sedang menganalisis struk Anda. Proses ini mungkin memakan waktu 10–30 detik.',
                        style: TextStyle(
                            color: Color(0xFF8A99AD), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    _mlKitTimer?.cancel();
                    _backendTimer?.cancel();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1F2E46)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow({
    required IconData icon,
    required String title,
    required double progress,
    required bool done,
  }) {
    final int pct = (progress * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : icon,
              color: done ? const Color(0xFF00E5A8) : Colors.grey,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: done ? Colors.white : const Color(0xFF8A99AD),
                  fontSize: 14,
                  fontWeight:
                      done ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '$pct%',
              style: const TextStyle(
                  color: Color(0xFF00E5A8),
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF141E2E),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
          ),
        ),
      ],
    );
  }
}

/// Internal enum to track the current processing stage
enum _Stage { mlKit, backend }
