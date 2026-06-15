// lib/services/photo_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api/api_client.dart';

class PhotoService {
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  PhotoService(this._apiClient);

  /// Upload photo to Backend API
  /// Returns the public URL of the uploaded photo
  Future<String> uploadProfilePhoto({
    required File photoFile,
    required String userId,
  }) async {
    try {
      final response = await _apiClient.uploadFile(
        '/users/profile/photo',
        photoFile.path,
        fieldName: 'photo',
      );

      final payload = response['data'] ?? response;
      final String photoUrl = payload['profile_picture']?.toString() ?? '';

      if (photoUrl.isEmpty) {
        throw PhotoUploadException('Gagal mendapatkan URL foto profil dari server.');
      }

      // Cache the photo URL locally
      await _secureStorage.write(key: 'user_profile_picture', value: photoUrl);

      return photoUrl;
    } on PhotoUploadException {
      rethrow;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('Unauthorized')) {
        throw PhotoUploadException('Sesi telah habis. Silakan login ulang.');
      }
      throw PhotoUploadException('Gagal upload foto: $msg');
    }
  }

  /// Delete old profile photo from storage (No-op on client, handled implicitly or ignored)
  Future<void> deleteProfilePhoto({required String photoUrl}) async {
    // Left as no-op since direct Supabase storage manipulation from client is bypassed
    debugPrint('[PhotoService] deleteProfilePhoto called for $photoUrl');
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
