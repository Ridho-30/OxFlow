import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/error_handler.dart';
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

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSymbol = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final value = _newPasswordController.text;
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSymbol = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  int _getStrengthScore() {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasNumber) score++;
    if (_hasSymbol) score++;
    return score;
  }

  String _getStrengthText(int score) {
    if (_newPasswordController.text.isEmpty) return '';
    if (score <= 1) return 'Lemah';
    if (score <= 3) return 'Sedang';
    return 'Kuat';
  }

  Color _getStrengthColor(int score) {
    if (score <= 1) return Colors.redAccent;
    if (score <= 3) return const Color(0xFFF2C94C); // Yellow/Orange
    return const Color(0xFF00E5A8); // Green
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    // if (_getStrengthScore() < 4) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'Kata sandi baru belum memenuhi semua kriteria keamanan',
    //       ),
    //       backgroundColor: Colors.redAccent,
    //     ),
    //   );
    //   return;
    // }
    if (_oldPasswordController.text == _newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kata sandi baru tidak boleh sama dengan kata sandi lama',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog then redirect to login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF141E2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Berhasil',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Kata sandi Anda berhasil diubah! Anda akan diarahkan ke halaman masuk untuk login kembali.',
              style: TextStyle(color: Color(0xFF8A99AD)),
            ),
          );
        },
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        // Logout local state & navigate to login
        ref.read(authProvider.notifier).logout();
        Navigator.pop(context); // Pop dialog
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      });
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

  @override
  Widget build(BuildContext context) {
    // final int strengthScore = _getStrengthScore();
    // final String strengthText = _getStrengthText(strengthScore);
    // final Color strengthColor = _getStrengthColor(strengthScore);

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
                // Old Password
                _buildLabel('Kata Sandi Lama'),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'Masukkan kata sandi lama',
                    obscure: _obscureOld,
                    toggleObscure: () =>
                        setState(() => _obscureOld = !_obscureOld),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Kata sandi lama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lupa kata sandi?',
                      style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // New Password
                _buildLabel('Kata Sandi Baru'),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'Masukkan kata sandi baru',
                    obscure: _obscureNew,
                    toggleObscure: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Kata sandi baru wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // // Password Strength Indicator
                // if (_newPasswordController.text.isNotEmpty) ...[
                //   Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       const Text(
                //         'Kekuatan Kata Sandi',
                //         style: TextStyle(color: Color(0xFF8A99AD), fontSize: 13),
                //       ),
                //       Text(
                //         strengthText,
                //         style: TextStyle(color: strengthColor, fontSize: 13, fontWeight: FontWeight.bold),
                //       ),
                //     ],
                //   ),
                //   const SizedBox(height: 8),
                //   Row(
                //     children: List.generate(4, (index) {
                //       final bool isFilled = index < strengthScore;
                //       return Expanded(
                //         child: Container(
                //           height: 5,
                //           margin: EdgeInsets.only(
                //             right: index < 3 ? 6 : 0,
                //           ),
                //           decoration: BoxDecoration(
                //             color: isFilled ? strengthColor : const Color(0xFF141E2E),
                //             borderRadius: BorderRadius.circular(2),
                //           ),
                //         ),
                //       );
                //     }),
                //   ),
                //   const SizedBox(height: 16),
                // ],

                // Password Requirements Checklist
                // const Text(
                //   'Kriteria Kata Sandi Baru:',
                //   style: TextStyle(
                //     color: Color(0xFF8A99AD),
                //     fontSize: 13,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 12),
                // _buildChecklistItem('Minimal 8 karakter', _hasMinLength),
                // _buildChecklistItem('Mengandung huruf besar (A-Z)', _hasUppercase),
                // _buildChecklistItem('Mengandung angka (0-9)', _hasNumber),
                // _buildChecklistItem('Mengandung simbol (!@#\$%^&*)', _hasSymbol),
                // const SizedBox(height: 24),

                // Confirm Password
                _buildLabel('Konfirmasi Kata Sandi Baru'),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'Konfirmasi kata sandi baru',
                    obscure: _obscureConfirm,
                    toggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Konfirmasi kata sandi wajib diisi';
                    if (value != _newPasswordController.text)
                      return 'Kata sandi tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Action Buttons
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00E5A8),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E5A8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
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
                                side: const BorderSide(
                                  color: Color(0xFF1F2E46),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
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

  // Widget _buildChecklistItem(String text, bool isChecked) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       children: [
  //         Icon(
  //           isChecked ? Icons.check_circle : Icons.circle_outlined,
  //           color: isChecked ? const Color(0xFF00E5A8) : Colors.grey,
  //           size: 18,
  //         ),
  //         const SizedBox(width: 8),
  //         Text(
  //           text,
  //           style: TextStyle(
  //             color: isChecked ? Colors.white : Colors.grey,
  //             fontSize: 13,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  InputDecoration _buildInputDecoration({
    required String hint,
    required bool obscure,
    required VoidCallback toggleObscure,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFF141E2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F2E46)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E5A8)),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
          size: 20,
        ),
        onPressed: toggleObscure,
      ),
    );
  }
}
