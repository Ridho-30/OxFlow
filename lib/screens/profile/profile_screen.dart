import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        elevation: 0,
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 20),

              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF141E2E),
                child: Icon(Icons.person, size: 50, color: Color(0xFF00E5A8)),
              ),

              const SizedBox(height: 20),

              const Text(
                'Richo Hanisyaputra',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'richo12@email.com',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              _buildMenuItem(icon: Icons.edit_outlined, title: 'Edit Profil'),

              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Ganti Kata Sandi',
              ),

              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifikasi',
              ),

              _buildMenuItem(icon: Icons.info_outline, title: 'Tentang OxFlow'),

              const SizedBox(height: 20),

              _buildMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : const Color(0xFF00E5A8),
        ),

        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 18,
        ),
      ),
    );
  }
}
