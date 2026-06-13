import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final Function(String) onChanged;
  final String? initialValue;

  const CurrencyInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  late TextEditingController _controller;
  final _formatter = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    String formattedInitial = '';
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      final parsed = double.tryParse(widget.initialValue!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (parsed > 0) {
        formattedInitial = _formatter.format(parsed);
      }
    }
    _controller = TextEditingController(text: formattedInitial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _formatAndNotify(String value) {
    if (value.isEmpty) {
      widget.onChanged('');
      return;
    }

    // Strip non-digits
    final cleanString = value.replaceAll(RegExp(r'[^0-9]'), '');
    final number = double.tryParse(cleanString);

    if (number != null) {
      final formatted = _formatter.format(number);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      widget.onChanged(cleanString); // Notify with clean numeric string
    } else {
      widget.onChanged('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: _formatAndNotify,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF141E2E),
            prefixText: 'Rp ',
            prefixStyle: const TextStyle(color: Color(0xFF00E5A8), fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1F2E46)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1F2E46)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00E5A8)),
            ),
          ),
        ),
      ],
    );
  }
}
