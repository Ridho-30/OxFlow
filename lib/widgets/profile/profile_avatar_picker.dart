// lib/widgets/profile/profile_avatar_picker.dart

import 'dart:io';
import 'package:flutter/material.dart';

/// Avatar display + camera overlay button, extracted from [EditProfileScreen].
///
/// This widget is stateless — it only renders what it receives. Image picking
/// logic stays in the screen so this widget stays simple and reusable.
class ProfileAvatarPicker extends StatelessWidget {
  /// A locally selected [File] from the device (gallery / camera).
  /// Takes priority over [currentPhotoUrl] when not null.
  final File? selectedImage;

  /// The current remote photo URL stored in the user profile.
  final String? currentPhotoUrl;

  /// Called when the user taps the camera button.
  final VoidCallback onPickPhoto;

  const ProfileAvatarPicker({
    super.key,
    required this.onPickPhoto,
    this.selectedImage,
    this.currentPhotoUrl,
  });

  ImageProvider _resolveImage() {
    if (selectedImage != null) return FileImage(selectedImage!);
    if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty) {
      return NetworkImage(currentPhotoUrl!);
    }
    // Fallback: solid color (no asset dependency)
    return const AssetImage('assets/images/placeholder_avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // ── Avatar circle ──────────────────────────────────────────────
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00E5A8),
                  width: 3,
                ),
                image: DecorationImage(
                  image: _resolveImage(),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {}, // suppress network errors silently
                ),
              ),
            ),

            // ── Camera button overlay ──────────────────────────────────────
            GestureDetector(
              onTap: onPickPhoto,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5A8),
                  border: Border.all(
                    color: const Color(0xFF0B1220),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF0B1220),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to change photo',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
