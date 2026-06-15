// lib/services/ocr/receipt_parser.dart

import 'package:flutter/foundation.dart';

// ── Data Models ───────────────────────────────────────────────────────────────

class ParsedItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double itemSubtotal;

  ParsedItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.itemSubtotal,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'itemSubtotal': itemSubtotal,
      };

  @override
  String toString() =>
      'ParsedItem(name: $name, qty: $quantity, price: $unitPrice, subtotal: $itemSubtotal)';
}

class ParsedReceipt {
  final String storeName;
  final List<ParsedItem> items;
  final double subtotal;
  final double tax;
  final double total;

  ParsedReceipt({
    required this.storeName,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
      };

  @override
  String toString() =>
      'ParsedReceipt(store: $storeName, items: ${items.length}, subtotal: $subtotal, tax: $tax, total: $total)';
}

// ── Parser ────────────────────────────────────────────────────────────────────

class ReceiptParser {
  // ── Currency Helpers ────────────────────────────────────────────────────────

  /// Strips Rp / Rp. / IDR prefix and converts Indonesian number format to double.
  /// Handles: "15.000", "15.000,00", "Rp 82.500", "Rp. 7.500"
  static double parseIndonesianCurrency(String raw) {
    // Remove currency labels
    String s = raw
        .replaceAll(RegExp(r'Rp\.?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'IDR\s*', caseSensitive: false), '')
        .trim();

    // Keep only digits, dots, commas
    s = s.replaceAll(RegExp(r'[^0-9.,]'), '').trim();
    if (s.isEmpty) return 0.0;

    // Determine separator roles
    final hasDot = s.contains('.');
    final hasComma = s.contains(',');

    if (hasDot && hasComma) {
      // Both present — last one is decimal separator
      final lastDot = s.lastIndexOf('.');
      final lastComma = s.lastIndexOf(',');
      if (lastComma > lastDot) {
        // e.g. "15.000,50" → dot=thousands, comma=decimal
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // e.g. "15,000.50" → comma=thousands, dot=decimal
        s = s.replaceAll(',', '');
      }
    } else if (hasComma) {
      final parts = s.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        // decimal comma: "15,50"
        s = '${parts[0]}.${parts[1]}';
      } else {
        // thousands comma: "15,000"
        s = s.replaceAll(',', '');
      }
    } else if (hasDot) {
      // Indonesian: dot = thousands separator when 3 digits follow each dot
      final parts = s.split('.');
      final allThousands = parts.length > 1 &&
          parts.sublist(1).every((p) => p.length == 3);
      if (allThousands) {
        s = s.replaceAll('.', '');
      }
      // else keep as-is (actual decimal like "1.5")
    }

    return double.tryParse(s) ?? 0.0;
  }

  /// Extract the largest plausible price (>= minValue) from a text line.
  static double _extractLastPrice(String text, {double minValue = 100}) {
    // Matches: optional "Rp."/"Rp" prefix + number with dots/commas
    final re = RegExp(
      r'(?:Rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?|\d+)',
      caseSensitive: false,
    );
    double best = 0.0;
    for (final m in re.allMatches(text)) {
      final v = parseIndonesianCurrency(m.group(0)!);
      if (v >= minValue && v > best) best = v;
    }
    return best;
  }

  // ── Name Cleanup ────────────────────────────────────────────────────────────

  static String _cleanName(String raw) {
    return raw
        .replaceAll(RegExp(r'^[\d\s]+'), '') // leading row-number
        .replaceAll(RegExp(r'[=\-*+/\\:|]'), '')
        .trim();
  }

  // ── Main Parser ─────────────────────────────────────────────────────────────

  static ParsedReceipt parse(String rawText) {
    debugPrint('[ReceiptParser] RAW:\n$rawText');

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // ── Step 1: Find store name ─────────────────────────────────────────────
    //
    // Strategy: scan from the TOP of the OCR output and take the FIRST line
    // that looks like a proper store/merchant name.
    // Skip lines that are: payment processors, addresses, phone, table headers,
    // separators, watermarks/license text, and pure-number codes.
    //
    final storeSkip = RegExp(
      r'(qris|bank\s+mandiri|bank\s+bca|bank\s+bri|bank\s+bni|bank\s+btn|'
      r'gopay|ovo|dana|shopeepay|linkaja|'
      r'jl\.|jalan|gg\.|gang|rt\s*\d|rw\s*\d|'
      r'telp|telepon|phone|fax|hp\s*:|'
      r'http|www\.|@|\.com|\.id|'
      r'meja\s*\d|code\s+tr|kode\s+tr|no\s+meja|table|'
      r'wib|wita|wit|'
      r'no\s+menu|no\.\s*menu|harga\s+qty|qty\s+jumlah|'
      r'subtotal|sub\s*total|grand\s*total|'
      r'free\s+for|personal\s+use|commercial\s+use|requires|license|'
      r'powered\s+by|app\s+is\s+free|'
      r'struk|receipt|invoice|faktur|nota)',
      caseSensitive: false,
    );
    final separatorRe = RegExp(r'^[\-=_*\.]{3,}$');
    final pureNumberRe = RegExp(r'^[\d\s\-:./,+()]+$');

    String storeName = 'Toko Baru';
    for (final line in lines) {
      if (line.length < 2) continue;
      if (separatorRe.hasMatch(line)) continue;
      if (pureNumberRe.hasMatch(line)) continue;
      if (storeSkip.hasMatch(line.toLowerCase())) continue;
      // Skip lines that are mostly non-letter (transaction codes, etc.)
      final letters = line.replaceAll(RegExp(r'[^a-zA-Z]'), '').length;
      if (letters < 2) continue;
      storeName = _cleanName(line);
      if (storeName.isNotEmpty) break;
    }

    // ── Step 2: Parse body ──────────────────────────────────────────────────
    //
    // For each line determine if it is: TAX, SUBTOTAL, TOTAL, or an ITEM.
    //
    final taxRe = RegExp(
      r'\b(pajak|ppn|pb1|pbi|tax|service\s*charge|srv\.?\s*charge)\b',
      caseSensitive: false,
    );
    final subtotalRe = RegExp(
      r'\b(subtotal|sub\s*total)\b',
      caseSensitive: false,
    );
    final totalRe = RegExp(
      r'\b(grand\s*total|total\s*bayar|total\s*belanja|total)\b',
      caseSensitive: false,
    );
    // Lines to skip entirely (not item candidates)
    final skipLine = RegExp(
      r'\b(bayar|tunai|cash|kembali|kembalian|kembal|change|'
      r'debit|kredit|kartu|member|diskon|promo|'
      r'tagihan|tagihan\s*:|terbayar|'
      r'no\s+menu|no\.\s*menu|harga\s+qty|qty\s+harga|'
      r'terima\s*kasih|thank\s*you|'
      r'free\s+for|personal\s+use|commercial|requires|license|powered\s+by|'
      r'meja|code\s*tr|kode\s*tr|'
      r'jl\.|jalan|telp|phone)\b',
      caseSensitive: false,
    );

    // Item regex patterns (tried in order, most specific first):
    //
    // Pattern A — "NO  NAME  PRICE  QTY  Rp.  JUMLAH"
    //   e.g. "1 LEMONADE ICE 15.000 1 Rp. 15.000"
    //        "2 CHICKEN CURY 25.000 2 Rp. 50.000"
    final itemA = RegExp(
      r'^(\d+)\s+(.+?)\s+(\d[\d.,]*)\s+(\d{1,3})\s+(?:Rp\.?\s*)?(\d[\d.,]*)$',
      caseSensitive: false,
    );

    // Pattern B — "NAME  QTY x PRICE  [SUBTOTAL]"
    //   e.g. "Nasi Goreng 2 x 25.000 50.000"
    final itemB = RegExp(
      r'^(.+?)\s+(\d{1,3})\s*[xX]\s*(?:Rp\.?\s*)?(\d[\d.,]+)(?:\s+(?:Rp\.?\s*)?(\d[\d.,]+))?$',
      caseSensitive: false,
    );

    // Pattern C — "NAME  QTY  PRICE"  (qty is small: 1-99)
    //   e.g. "KOPI HITAM 2 10.000"
    final itemC = RegExp(
      r'^(.+?)\s+(\d{1,2})\s+(?:Rp\.?\s*)?(\d[\d.,]+)$',
      caseSensitive: false,
    );

    // Pattern D — "[NO]  NAME  PRICE"  (qty assumed 1)
    //   e.g. "Es Cincau 10.000" or "3 Es Cincau 10.000"
    final itemD = RegExp(
      r'^(?:\d+\s+)?(.+?)\s+(?:Rp\.?\s*)?(\d[\d.,]+)$',
      caseSensitive: false,
    );

    final List<ParsedItem> items = [];
    double subtotal = 0.0;
    double tax = 0.0;
    double total = 0.0;

    for (final line in lines) {
      final lower = line.toLowerCase();

      // Skip separators
      if (separatorRe.hasMatch(line)) continue;
      if (line.contains('===') || line.contains('---') || line.contains('___')) {
        continue;
      }

      // Skip non-item boilerplate
      if (skipLine.hasMatch(lower)) continue;

      // ── Tax line ─────────────────────────────────────────────────────────
      if (taxRe.hasMatch(lower)) {
        // "PB1 10 % Rp. 7.500" — want 7500, not 10
        final price = _extractLastPrice(line, minValue: 100);
        if (price > 0) tax = price;
        continue;
      }

      // ── Subtotal line ─────────────────────────────────────────────────────
      if (subtotalRe.hasMatch(lower)) {
        final price = _extractLastPrice(line, minValue: 0);
        if (price > 0) subtotal = price;
        continue;
      }

      // ── Total line ────────────────────────────────────────────────────────
      if (totalRe.hasMatch(lower)) {
        final price = _extractLastPrice(line, minValue: 0);
        if (price > 0 && !subtotalRe.hasMatch(lower)) total = price;
        continue;
      }

      // ── Item Pattern A ────────────────────────────────────────────────────
      final mA = itemA.firstMatch(line);
      if (mA != null) {
        final name = _cleanName(mA.group(2)!);
        final price = parseIndonesianCurrency(mA.group(3)!);
        final qty = int.tryParse(mA.group(4)!) ?? 1;
        final itemSub = parseIndonesianCurrency(mA.group(5)!);
        if (name.length >= 2 && (price > 0 || itemSub > 0)) {
          items.add(ParsedItem(
            name: name,
            quantity: qty,
            unitPrice: price > 0 ? price : (qty > 0 ? itemSub / qty : 0),
            itemSubtotal: itemSub > 0 ? itemSub : qty * price,
          ));
        }
        continue;
      }

      // ── Item Pattern B ────────────────────────────────────────────────────
      final mB = itemB.firstMatch(line);
      if (mB != null) {
        final name = _cleanName(mB.group(1)!);
        final qty = int.tryParse(mB.group(2)!) ?? 1;
        final price = parseIndonesianCurrency(mB.group(3)!);
        final itemSub = mB.group(4) != null
            ? parseIndonesianCurrency(mB.group(4)!)
            : qty * price;
        if (name.length >= 2 && price > 0) {
          items.add(ParsedItem(
            name: name,
            quantity: qty,
            unitPrice: price,
            itemSubtotal: itemSub,
          ));
        }
        continue;
      }

      // ── Item Pattern C ────────────────────────────────────────────────────
      final mC = itemC.firstMatch(line);
      if (mC != null) {
        final name = _cleanName(mC.group(1)!);
        final qty = int.tryParse(mC.group(2)!) ?? 1;
        final price = parseIndonesianCurrency(mC.group(3)!);
        if (name.length >= 2 && price > 0) {
          items.add(ParsedItem(
            name: name,
            quantity: qty,
            unitPrice: price,
            itemSubtotal: qty * price,
          ));
          continue;
        }
      }

      // ── Item Pattern D ────────────────────────────────────────────────────
      final mD = itemD.firstMatch(line);
      if (mD != null) {
        final name = _cleanName(mD.group(1)!);
        final price = parseIndonesianCurrency(mD.group(2)!);
        // Only treat as item if price is a plausible item price
        // and not the store name
        if (name.length >= 2 &&
            price >= 500 &&
            !storeSkip.hasMatch(name.toLowerCase()) &&
            name.toLowerCase() != storeName.toLowerCase()) {
          items.add(ParsedItem(
            name: name,
            quantity: 1,
            unitPrice: price,
            itemSubtotal: price,
          ));
        }
      }
    }

    // ── Step 3: Fallback & normalization ────────────────────────────────────
    if (items.isEmpty) {
      // Single fallback item with the grand total as price
      final fallbackPrice = total > 0 ? total : subtotal;
      items.add(ParsedItem(
        name: 'Belanja Struk',
        quantity: 1,
        unitPrice: fallbackPrice,
        itemSubtotal: fallbackPrice,
      ));
    }

    if (subtotal == 0.0) {
      subtotal = items.fold(0.0, (s, i) => s + i.itemSubtotal);
    }
    if (total == 0.0) {
      total = subtotal + tax;
    }

    final result = ParsedReceipt(
      storeName: storeName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
    );

    debugPrint('[ReceiptParser] RESULT: $result');
    for (final item in items) {
      debugPrint('  └─ $item');
    }

    return result;
  }

  /// Quick local self-test — call from a debug screen to validate parser logic.
  static String runLocalTests() {
    final buf = StringBuffer()..writeln('=== RECEIPT PARSER TESTS ===\n');

    // JO CAFE — the real-world receipt from the screenshots
    const joCafe = '''
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
***app is free for personal use, commercial use requires license***
''';

    // Indomaret style
    const indomaret = '''
INDOMARET KAMPUNG UTAMA
JL. RAYA KAMPUNG UTAMA NO. 45
TELP: 021-1234567
================================
ROTI KASUR         1  x  15.000   15.000
AQUA BOTOL 600ML   2  x   3.500    7.000
CHIKI TARO         1  x   8.000    8.000
--------------------------------
SUBTOTAL               30.000
TOTAL                  30.000
''';

    // Warung kopi style
    const warkop = '''
WARUNG KOPI JEMBER
KOPI HITAM  2  10.000
ROTI BAKAR  1  15.000
JUMLAH         35.000
BAYAR          50.000
KEMBALIAN      15.000
''';

    // Cafe with grand total + pajak
    const cafe = '''
CAFE NUSANTARA
Jl. Malioboro No. 12
Nasi Goreng Spesial  1 x 25.000
Es Teh Manis         2 x  5.000
SUB TOTAL    35.000
Pajak 10%     3.500
GRAND TOTAL  38.500
''';

    for (final entry in {
      'JO CAFE': joCafe,
      'Indomaret': indomaret,
      'Warkop': warkop,
      'Cafe Nusantara': cafe,
    }.entries) {
      buf.writeln('--- ${entry.key} ---');
      try {
        final r = parse(entry.value);
        buf.writeln('Store   : ${r.storeName}');
        buf.writeln('Items   : ${r.items.length}');
        for (final i in r.items) {
          buf.writeln('  ${i.name} ${i.quantity}x @ ${i.unitPrice.toInt()} = ${i.itemSubtotal.toInt()}');
        }
        buf.writeln('Subtotal: ${r.subtotal.toInt()}');
        buf.writeln('Tax     : ${r.tax.toInt()}');
        buf.writeln('Total   : ${r.total.toInt()}');
      } catch (e) {
        buf.writeln('ERROR: $e');
      }
      buf.writeln();
    }

    buf.writeln('=== DONE ===');
    return buf.toString();
  }
}
