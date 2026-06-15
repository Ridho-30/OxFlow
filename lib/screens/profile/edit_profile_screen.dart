// lib/screens/profile/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/photo_provider.dart';
import '../../widgets/profile/profile_avatar_picker.dart';
import '../../widgets/profile/profile_form_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _nameController;

  bool _hasChanges = false;
  File? _selectedImage;
  String? _currentPhotoUrl;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _currentPhotoUrl = user?.profilePicture;
    _nameController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_checkForChanges)
      ..dispose();
    super.dispose();
  }

  // ── Change detection ───────────────────────────────────────────────────────

  void _checkForChanges() {
    final originalName = ref.read(authProvider).user?.name ?? '';
    final changed =
        _nameController.text != originalName || _selectedImage != null;
    if (changed != _hasChanges) setState(() => _hasChanges = changed);
  }

  // ── Image picking ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked =
          await _imagePicker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e', isError: true);
    }
  }

  void _showPhotoSourceDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Pilih Foto', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFF00E5A8)),
              title: const Text('Dari Galeri',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera, color: Color(0xFF00E5A8)),
              title: const Text('Ambil Foto',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Save logic ─────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authNotifier = ref.read(authProvider.notifier);
    final user = ref.read(authProvider).user;
    String photoUrlToSave = _currentPhotoUrl ?? '';

    // 1) Upload photo if a new one was selected
    if (_selectedImage != null) {
      try {
        _showLoadingDialog('Uploading photo...');
        final uploaded = await ref.read(photoUploadProvider.notifier).uploadPhoto(
              photoFile: _selectedImage!,
              userId: user?.userId ?? '',
            );
        photoUrlToSave = uploaded ?? _currentPhotoUrl ?? '';
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          _showSnackBar('Failed to upload photo: $e', isError: true);
        }
        return;
      }
    }

    // 2) Update profile name + photo URL
    try {
      if (!mounted) return;
      _showLoadingDialog('Saving profile...');
      await authNotifier.updateProfile(
        name: _nameController.text,
        profilePicture: photoUrlToSave,
      );
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Profile updated successfully!');
        setState(() {
          _selectedImage = null;
          _currentPhotoUrl = photoUrlToSave;
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Failed to save profile: $e', isError: true);
      }
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF00E5A8)),
            ),
            const SizedBox(width: 16),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF00E5A8),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Only rebuild the save button area when upload state changes
    final isUploading = ref.watch(
      photoUploadProvider.select((s) => s.isLoading),
    );
    final uploadError = ref.watch(
      photoUploadProvider.select((s) => s.error),
    );

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
          'Edit Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar picker ────────────────────────────────────────────
              Center(
                child: ProfileAvatarPicker(
                  selectedImage: _selectedImage,
                  currentPhotoUrl: _currentPhotoUrl,
                  onPickPhoto: _showPhotoSourceDialog,
                ),
              ),

              // ── Upload error banner ──────────────────────────────────────
              if (uploadError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      uploadError,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // ── Name field ───────────────────────────────────────────────
              const ProfileFieldLabel('Full Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    profileInputDecoration(hint: 'Enter your full name'),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Name cannot be empty' : null,
              ),

              const SizedBox(height: 32),

              // ── Save button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_hasChanges && !isUploading) ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5A8),
                    disabledBackgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Color(0xFF0B1220),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
