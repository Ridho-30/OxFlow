// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile/profile_menu_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF141E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar? Anda akan diminta login kembali.',
          style: TextStyle(color: Color(0xFF8A99AD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, WidgetRef ref) {
    final inputController = TextEditingController();
    bool isButtonEnabled = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final isLoading = ref.watch(authProvider).isLoading;
          
          return AlertDialog(
            backgroundColor: const Color(0xFF141E2E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Hapus Akun',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tindakan ini tidak dapat dibatalkan. Semua data akun kamu akan dihapus permanen.',
                  style: TextStyle(color: Color(0xFF8A99AD)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: inputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Ketik 'Hapus Akun' untuk konfirmasi",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0B1220),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isButtonEnabled = value.trim() == "Hapus Akun";
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: (!isButtonEnabled || isLoading)
                    ? null
                    : () async {
                        try {
                          await ref.read(authProvider.notifier).deleteAccount();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext); // close dialog
                            Navigator.pushAndRemoveUntil(
                              dialogContext,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Akun berhasil dihapus', style: TextStyle(color: Colors.white)),
                                backgroundColor: Color(0xFF0C2B29),
                              ),
                            );
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus akun: $e', style: const TextStyle(color: Colors.white)),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: Colors.redAccent.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Hapus Akun',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select() only rebuilds this screen when the user object changes,
    // not when isLoading / error / isCheckingAuth changes.
    final user = ref.watch(authProvider.select((s) => s.user));
    final userName = user?.name ?? 'Pengguna';
    final userEmail = user?.email ?? '';
    final profilePicture = user?.profilePicture ?? '';
    final hasValidPicture = profilePicture.startsWith('http');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Avatar ──────────────────────────────────────────────────
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF141E2E),
                backgroundImage:
                    hasValidPicture ? NetworkImage(profilePicture) : null,
                child: !hasValidPicture
                    ? const Icon(Icons.person,
                        size: 50, color: Color(0xFF00E5A8))
                    : null,
              ),
              const SizedBox(height: 20),

              // ── User info ────────────────────────────────────────────────
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                userEmail,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // ── Menu items ───────────────────────────────────────────────
              ProfileMenuItem(
                icon: Icons.edit_outlined,
                title: 'Edit Profil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                ),
              ),
              ProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Ganti Kata Sandi',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                ),
              ),
              const SizedBox(height: 20),
              ProfileMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                isLogout: true,
                onTap: () => _showLogoutConfirmation(context, ref),
              ),
              const SizedBox(height: 20),
              ProfileMenuItem(
                icon: Icons.delete_forever,
                title: 'Hapus Akun',
                isLogout: true, // Use red color styling
                onTap: () => _showDeleteAccountConfirmation(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
