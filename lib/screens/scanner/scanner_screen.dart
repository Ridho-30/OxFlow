import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_processing_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Pindai Struk',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Expanded(
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: const Color(0xFF141E2E),

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: const Color(
                      0xFF00E5A8,
                    ),
                    width: 2,
                  ),
                ),

                child: const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Icon(
                      Icons.document_scanner,
                      size: 80,
                      color: Color(
                        0xFF00E5A8,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Posisikan struk\ndi dalam area pemindaian',

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(
                        color:
                            Colors.white,

                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Pastikan seluruh isi struk terlihat dengan jelas',

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  try {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OcrProcessingScreen(
                            imagePath: image.path,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OcrProcessingScreen(
                          imagePath: 'assets/images/struk_mock.png',
                        ),
                      ),
                    );
                  }
                },

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF00E5A8,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child: const Text(
                  'Pindai Struk',

                  style: TextStyle(
                    color:
                        Colors.black,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}