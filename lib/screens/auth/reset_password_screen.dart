// lib/screens/auth/reset_password_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/password_requirement_item.dart';
import '../../widgets/profile/profile_form_field.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Password strength flags — updated on each keystroke
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  bool _isLoading = false;

  bool get _allRequirementsMet =>
      _hasMinLength && _hasUppercase && _hasNumber && _hasSymbol;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController
      ..removeListener(_validatePassword)
      ..dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final v = _newPasswordController.text;
    setState(() {
      _hasMinLength = v.length >= 8;
      _hasUppercase = v.contains(RegExp(r'[A-Z]'));
      _hasNumber = v.contains(RegExp(r'[0-9]'));
      _hasSymbol = v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_allRequirementsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Kata sandi baru belum memenuhi semua kriteria keamanan'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API request
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF141E2E),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Berhasil',
              style: TextStyle(color: Colors.white)),
          content: const Text(
            'Kata sandi berhasil diubah! Silakan login kembali dengan kata sandi baru Anda.',
            style: TextStyle(color: Color(0xFF8A99AD)),
          ),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Atur Ulang Kata Sandi',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── Header ───────────────────────────────────────────────
                const Center(
                  child: Icon(Icons.security_outlined,
                      size: 80, color: Color(0xFF00E5A8)),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Buat Kata Sandi Baru',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Password Anda akan segera diubah',
                    style: TextStyle(
                        color: Color(0xFF8A99AD), fontSize: 15),
                  ),
                ),
                const SizedBox(height: 40),

                // ── New password ─────────────────────────────────────────
                const ProfileFieldLabel('Kata Sandi Baru'),
                AuthTextField(
                  controller: _newPasswordController,
                  hint: 'Masukkan kata sandi baru',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Kata sandi baru wajib diisi'
                      : null,
                ),
                const SizedBox(height: 20),

                // ── Password requirements checklist ──────────────────────
                const Text(
                  'Kriteria Kata Sandi Baru:',
                  style: TextStyle(
                      color: Color(0xFF8A99AD),
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                PasswordRequirementItem(
                    label: 'Minimal 8 karakter',
                    isMet: _hasMinLength),
                PasswordRequirementItem(
                    label: 'Mengandung huruf besar (A-Z)',
                    isMet: _hasUppercase),
                PasswordRequirementItem(
                    label: 'Mengandung angka (0-9)',
                    isMet: _hasNumber),
                PasswordRequirementItem(
                    label: 'Mengandung simbol (!@#\$%^&*)',
                    isMet: _hasSymbol),
                const SizedBox(height: 24),

                // ── Confirm password ─────────────────────────────────────
                const ProfileFieldLabel('Konfirmasi Kata Sandi'),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hint: 'Konfirmasi kata sandi baru',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
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

                // ── Submit / loading ─────────────────────────────────────
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E5A8)),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5A8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        'Atur Ulang Kata Sandi',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 30),

                // ── Back to login link ───────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (route) => false,
                    ),
                    child: const Text(
                      'Kembali ke halaman login',
                      style: TextStyle(
                        color: Color(0xFF00E5A8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
