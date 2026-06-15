// lib/widgets/auth/auth_input_field.dart

import 'package:flutter/material.dart';

// ── Shared constants ──────────────────────────────────────────────────────────

const _kFillColor = Color(0xFF1A2332);
const _kFocusColor = Color(0xFF00E5A8);
const _kBorderRadius = 15.0;

/// Shared [InputDecoration] factory for all Auth screens.
/// Uses the dark-navy fill (`0xFF1A2332`) and borderless style used across
/// Login, Register, and ForgotPassword.
InputDecoration authInputDecoration({
  required String hint,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: _kFillColor,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: _kFocusColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    prefixIcon: Icon(prefixIcon, color: Colors.grey),
    suffixIcon: suffixIcon,
    errorStyle: const TextStyle(color: Colors.redAccent),
  );
}

// ── AuthTextField ─────────────────────────────────────────────────────────────

/// A styled text field for auth screens.
///
/// When [isPassword] is true, the widget self-manages visibility toggle state
/// so the parent screen doesn't need any extra bool/setState for each field.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: authInputDecoration(
        hint: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}
