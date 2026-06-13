import 'dart:io';
import 'package:flutter/material.dart';
import 'ocr_processing_screen.dart';

class GalleryPreviewScreen extends StatelessWidget {
  final String imagePath;
  const GalleryPreviewScreen({super.key, required this.imagePath});

  // Helper to get file size string safely
  String _getFileSize() {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        final mb = bytes / (1024 * 1024);
        return '${mb.toStringAsFixed(2)} MB';
      }
    } catch (_) {}
    return '2.45 MB'; // Mock fallback
  }

  // Helper to get extension
  String _getFileFormat() {
    try {
      final ext = imagePath.split('.').last.toUpperCase();
      if (ext.length <= 4) return ext;
    } catch (_) {}
    return 'JPG'; // Mock fallback
  }

  @override
  Widget build(BuildContext context) {
    final sizeText = _getFileSize();
    final formatText = _getFileFormat();
    final isAsset = imagePath.startsWith('assets/');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Preview Gambar dari Galeri',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image Preview Container with Pinch to Zoom
            Expanded(
              child: Container(
                color: Colors.black,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: isAsset
                        ? Image.asset(imagePath, fit: BoxFit.contain)
                        : (File(imagePath).existsSync()
                            ? Image.file(File(imagePath), fit: BoxFit.contain)
                            : Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141E2E),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.image, size: 60, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('Struk_Sample_Image.jpg', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              )),
                  ),
                ),
              ),
            ),

            // File metadata container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF141E2E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi File:',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaColumn('Ukuran File', sizeText),
                      _buildMetaColumn('Resolusi', '1920 x 1080'),
                      _buildMetaColumn('Format', formatText),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Warning indicators if size is suspicious
                  if (sizeText.contains('MB') && double.parse(sizeText.split(' ').first) > 5.0)
                    _buildWarningBanner('File terlalu besar! Disarankan di bawah 5MB.')
                  else if (sizeText.contains('KB') || (sizeText.contains('MB') && double.parse(sizeText.split(' ').first) < 0.1))
                    _buildWarningBanner('File terlalu kecil! Pastikan gambar beresolusi cukup tinggi.'),

                  const SizedBox(height: 12),

                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1F2E46)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Ganti Gambar',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OcrProcessingScreen(imagePath: imagePath),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5A8),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Lanjutkan ke OCR',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1F24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
