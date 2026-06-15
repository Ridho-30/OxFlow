// lib/services/ocr/ocr_service.dart
//
// Mengirim raw OCR text ke backend /api/ocr/parse (Gemini LLM) dan
// mengembalikan ParsedReceipt yang siap dipakai di halaman Validasi.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_endpoints.dart';
import '../api/dio_config.dart';
import '../../constants/api_constants.dart';
import 'receipt_parser.dart';

// ── Response model dari backend /api/ocr/parse ────────────────────────────────

class OcrBackendItem {
  final String namaBarang;
  final int qty;
  final double hargaSatuan;
  final double subtotal;

  OcrBackendItem({
    required this.namaBarang,
    required this.qty,
    required this.hargaSatuan,
    required this.subtotal,
  });

  factory OcrBackendItem.fromJson(Map<String, dynamic> json) {
    return OcrBackendItem(
      namaBarang: (json['nama_barang'] ?? json['namaBarang'] ?? '').toString(),
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      hargaSatuan: (json['harga_satuan'] ?? json['hargaSatuan'] as num?)
              ?.toDouble() ??
          0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OcrBackendPajak {
  final String? label;
  final double nominal;

  OcrBackendPajak({this.label, required this.nominal});

  factory OcrBackendPajak.fromJson(Map<String, dynamic> json) {
    return OcrBackendPajak(
      label: json['label']?.toString(),
      nominal: (json['nominal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OcrBackendResult {
  final String merchant;
  final List<OcrBackendItem> items;
  final OcrBackendPajak pajak;
  final double subtotalItems;
  final double grandTotal;

  OcrBackendResult({
    required this.merchant,
    required this.items,
    required this.pajak,
    required this.subtotalItems,
    required this.grandTotal,
  });

  factory OcrBackendResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final rawItems = data['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(OcrBackendItem.fromJson)
        .toList();

    final pajakRaw = data['pajak'];
    final pajak = pajakRaw is Map<String, dynamic>
        ? OcrBackendPajak.fromJson(pajakRaw)
        : OcrBackendPajak(nominal: 0.0);

    return OcrBackendResult(
      merchant: (data['merchant'] ?? '').toString(),
      items: items,
      pajak: pajak,
      subtotalItems:
          (data['subtotal_items'] ?? data['subtotalItems'] as num?)
                  ?.toDouble() ??
              0.0,
      grandTotal:
          (data['grand_total'] ?? data['grandTotal'] as num?)?.toDouble() ??
              0.0,
    );
  }

  /// Convert backend result to ParsedReceipt for use in TransactionFormFields
  ParsedReceipt toParsedReceipt() {
    final parsedItems = items
        .map((i) => ParsedItem(
              name: i.namaBarang,
              quantity: i.qty,
              unitPrice: i.hargaSatuan,
              itemSubtotal: i.subtotal,
            ))
        .toList();

    return ParsedReceipt(
      storeName: merchant.isNotEmpty ? merchant : 'Toko Baru',
      items: parsedItems,
      subtotal: subtotalItems,
      tax: pajak.nominal,
      total: grandTotal,
    );
  }
}

// ── Custom exception ──────────────────────────────────────────────────────────

class OcrServiceException implements Exception {
  final String message;
  final bool isNetworkError;

  OcrServiceException(this.message, {this.isNetworkError = false});

  @override
  String toString() => message;
}

// ── Service ───────────────────────────────────────────────────────────────────

class OcrService {
  /// Kirim [rawText] ke backend dan kembalikan [ParsedReceipt].
  ///
  /// Throws [OcrServiceException] jika:
  /// - network error / timeout
  /// - backend mengembalikan success=false
  /// - response format tidak valid
  static Future<ParsedReceipt> parseViaBackend(String rawText) async {
    debugPrint('[OcrService] Sending ${rawText.length} chars to backend...');

    // Gunakan Dio yang sudah dikonfigurasikan (auth interceptor sudah ter-attach)
    // dengan receive timeout yang lebih panjang untuk LLM call
    final dio = DioConfig.createDio();
    dio.options.receiveTimeout = ApiConstants.ocrReceiveTimeout;

    try {
      final response = await dio.post(
        ApiEndpoints.ocrParse,
        data: {'rawText': rawText},
      );

      final body = response.data;
      debugPrint('[OcrService] Response: $body');

      // Backend mengembalikan { success: true, data: {...} }
      if (body is Map<String, dynamic>) {
        final success = body['success'] == true;
        if (!success) {
          final errMsg = body['error']?.toString() ??
              body['message']?.toString() ??
              'Gagal memproses struk';
          throw OcrServiceException(errMsg);
        }

        final result = OcrBackendResult.fromJson(body);
        final parsed = result.toParsedReceipt();
        debugPrint('[OcrService] Parsed: $parsed');
        return parsed;
      }

      throw OcrServiceException('Format response backend tidak valid');
    } on OcrServiceException {
      rethrow;
    } on DioException catch (e) {
      debugPrint('[OcrService] DioException: $e');

      // Timeout
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw OcrServiceException(
          'Koneksi ke server timeout. Periksa koneksi internet Anda.',
          isNetworkError: true,
        );
      }

      // Connection error
      if (e.type == DioExceptionType.connectionError) {
        throw OcrServiceException(
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          isNetworkError: true,
        );
      }

      // HTTP error response
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;
        final msg = (data is Map ? data['error'] ?? data['message'] : null)
                ?.toString() ??
            'Error $statusCode dari server';
        throw OcrServiceException(msg);
      }

      throw OcrServiceException(
        'Gagal menghubungi server: ${e.message}',
        isNetworkError: true,
      );
    } catch (e) {
      if (e is OcrServiceException) rethrow;
      debugPrint('[OcrService] Unexpected error: $e');
      throw OcrServiceException('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
