// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../navigation/main_navigation_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getErrorMessage(e)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // select() — only rebuild this screen when isLoading changes
    final isLoading =
        ref.watch(authProvider.select((s) => s.isLoading));

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Header ───────────────────────────────────────────────
                const Center(
                  child: Icon(
                    Icons.person_add_alt_1,
                    size: 70,
                    color: Color(0xFF00E5A8),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ── Full name ────────────────────────────────────────────
                const Text('Nama Lengkap',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _nameController,
                  hint: 'Masukkan nama lengkap',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 20),

                // ── Email ────────────────────────────────────────────────
                const Text('Email', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _emailController,
                  hint: 'example@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(v.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Password ─────────────────────────────────────────────
                const Text('Kata Sandi',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                    if (v.length < 8) return 'Kata sandi minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Confirm password ─────────────────────────────────────
                const Text('Konfirmasi Kata Sandi',
                    style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (v != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),

                // ── Register button ──────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5A8),
                      disabledBackgroundColor: const Color(0xFF141E2E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF00E5A8)),
                            ),
                          )
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // ── Login link ───────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sudah memiliki akun? Masuk',
                      style: TextStyle(color: Color(0xFF00E5A8)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}