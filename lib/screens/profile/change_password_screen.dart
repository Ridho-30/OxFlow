// lib/screens/profile/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';
import '../../widgets/profile/profile_form_field.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Submit logic ───────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_oldPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Kata sandi baru tidak boleh sama dengan kata sandi lama'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).changePassword(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success message and go back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi Anda berhasil diubah!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getErrorMessage(e)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ganti Kata Sandi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Old password ─────────────────────────────────────────
                const ProfileFieldLabel('Kata Sandi Lama'),
                ProfilePasswordField(
                  controller: _oldPasswordController,
                  hint: 'Masukkan kata sandi lama',
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Kata sandi lama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen()),
                    ),
                    child: const Text(
                      'Lupa kata sandi?',
                      style:
                          TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── New password ─────────────────────────────────────────
                const ProfileFieldLabel('Kata Sandi Baru'),
                ProfilePasswordField(
                  controller: _newPasswordController,
                  hint: 'Masukkan kata sandi baru',
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Kata sandi baru wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Confirm password ─────────────────────────────────────
                const ProfileFieldLabel('Konfirmasi Kata Sandi Baru'),
                ProfilePasswordField(
                  controller: _confirmPasswordController,
                  hint: 'Konfirmasi kata sandi baru',
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (v != _newPasswordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // ── Action buttons ───────────────────────────────────────
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E5A8)),
                    ),
                  )
                else
                  _ActionButtons(onSubmit: _handleSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private action buttons widget ─────────────────────────────────────────────

/// Extracted as a private const-capable widget so the button row does not
/// rebuild when the parent state changes (e.g., field validation updates).
class _ActionButtons extends StatelessWidget {
  final VoidCallback onSubmit;

  const _ActionButtons({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5A8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text(
              'Ganti Kata Sandi',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1F2E46)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
