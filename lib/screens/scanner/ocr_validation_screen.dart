import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ocr/receipt_parser.dart';
import '../../widgets/transaction_form_fields.dart';
import '../navigation/main_navigation_screen.dart';

class OcrValidationScreen extends ConsumerWidget {
  final String imagePath;
  final ParsedReceipt parsedReceipt;

  const OcrValidationScreen({
    super.key,
    required this.imagePath,
    required this.parsedReceipt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAsset = imagePath.startsWith('assets/');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Validasi Hasil Pemindaian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OCR Preview Card if image is available
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141E2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1F2E46)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // Small thumbnail of the receipt image
                    Container(
                      width: 90,
                      height: 90,
                      color: Colors.black,
                      child: isAsset
                          ? Image.asset(imagePath, fit: BoxFit.cover)
                          : (File(imagePath).existsSync()
                              ? Image.file(File(imagePath), fit: BoxFit.cover)
                              : const Icon(Icons.document_scanner, color: Color(0xFF00E5A8), size: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Pindai OCR Selesai',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Berikut adalah hasil ekstraksi struk belanja Anda. Koreksi data yang kurang tepat sebelum menyimpan.',
                            style: TextStyle(color: Color(0xFF8A99AD), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),

              // Transaction form fields modularized
              TransactionFormFields(
                initialData: parsedReceipt,
                imagePath: imagePath,
                onSuccess: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                onCancel: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
