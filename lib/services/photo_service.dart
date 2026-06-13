// lib/services/photo_service.dart

import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoService {
  final _secureStorage = const FlutterSecureStorage();
  final _supabase = Supabase.instance.client;

  static const String _bucketName = 'profile-pictures';
  static const String _storagePath = 'profile-pictures';

  /// Upload photo to Supabase storage
  /// Returns the public URL of the uploaded photo
  Future<String> uploadProfilePhoto({
    required File photoFile,
    required String userId,
  }) async {
    try {
      // Generate unique file name with timestamp
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fullPath = '$_storagePath/$fileName';

      // Upload to Supabase storage
      await _supabase.storage
          .from(_bucketName)
          .upload(
            fullPath,
            photoFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fullPath);

      // Cache the photo URL locally
      await _secureStorage.write(key: 'user_profile_picture', value: publicUrl);

      return publicUrl;
    } on StorageException catch (e) {
      throw PhotoUploadException('Upload failed: ${e.message}');
    } catch (e) {
      throw PhotoUploadException('Unexpected error: $e');
    }
  }

  /// Delete old profile photo from storage
  Future<void> deleteProfilePhoto({required String photoUrl}) async {
    try {
      // Extract file path from public URL
      // Format: https://...storage.supabase.co/object/public/bucket/path
      if (!photoUrl.contains(_bucketName)) return;

      final pathStart = photoUrl.indexOf(_bucketName) + _bucketName.length + 1;
      final filePath = photoUrl.substring(pathStart);

      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      // Log error but don't throw - deletion is not critical
      print('Failed to delete old photo: $e');
    }
  }

  /// Get cached profile photo URL
  Future<String?> getCachedPhotoUrl() async {
    return await _secureStorage.read(key: 'user_profile_picture');
  }

  /// Clear cached photo URL
  Future<void> clearCachedPhotoUrl() async {
    await _secureStorage.delete(key: 'user_profile_picture');
  }
}

class PhotoUploadException implements Exception {
  final String message;
  PhotoUploadException(this.message);

  @override
  String toString() => message;
}
