// lib/widgets/profile/profile_menu_item.dart

import 'package:flutter/material.dart';

/// Reusable menu item tile used in the Profile screen.
/// Using a proper [StatelessWidget] (not a method) allows the Flutter
/// framework to skip rebuilding unchanged items independently.
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
        isLogout ? Colors.redAccent : const Color(0xFF00E5A8);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF141E2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1F2E46), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: accentColor),
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
