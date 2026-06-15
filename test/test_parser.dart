// test/test_parser.dart
import '../lib/services/ocr/receipt_parser.dart';

void main() {
  final results = ReceiptParser.runLocalTests();
  print(results);
}
