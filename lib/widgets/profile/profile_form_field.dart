// lib/widgets/profile/profile_form_field.dart

import 'package:flutter/material.dart';

// ── App-wide input decoration theme constants ────────────────────────────────

const _kBorderRadius = 12.0;
const _kBorderColor = Color(0xFF1F2E46);
const _kFocusColor = Color(0xFF00E5A8);
const _kFillColor = Color(0xFF141E2E);

/// Shared [InputDecoration] factory used by both [EditProfileScreen] and
/// [ChangePasswordScreen]. Single source of truth — no more duplication.
InputDecoration profileInputDecoration({
  required String hint,
  bool hasToggle = false,
  bool isObscured = false,
  VoidCallback? onToggleObscure,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    filled: true,
    fillColor: _kFillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: _kBorderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: _kBorderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: _kFocusColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_kBorderRadius),
      borderSide: const BorderSide(color: Colors.transparent),
    ),
    suffixIcon: hasToggle
        ? IconButton(
            icon: Icon(
              isObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onToggleObscure,
          )
        : null,
  );
}

// ── ProfileFieldLabel ────────────────────────────────────────────────────────

/// Small section label rendered above a form field.
class ProfileFieldLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const ProfileFieldLabel(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(bottom: 8, left: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── ProfilePasswordField ─────────────────────────────────────────────────────

/// Password [TextFormField] with built-in toggle visibility — eliminates the
/// repetitive pattern of 3 nearly-identical fields in [ChangePasswordScreen].
class ProfilePasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;

  const ProfilePasswordField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
  });

  @override
  State<ProfilePasswordField> createState() => _ProfilePasswordFieldState();
}

class _ProfilePasswordFieldState extends State<ProfilePasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: profileInputDecoration(
        hint: widget.hint,
        hasToggle: true,
        isObscured: _obscure,
        onToggleObscure: () => setState(() => _obscure = !_obscure),
      ),
      validator: widget.validator,
    );
  }
}
