// lib/providers/photo_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/photo_service.dart';
import 'auth_provider.dart';

final photoServiceProvider = Provider<PhotoService>((ref) => PhotoService(ref.read(apiClientProvider)));

// State untuk tracking upload progress
class PhotoUploadState {
  final bool isLoading;
  final String? photoUrl;
  final String? error;

  const PhotoUploadState({this.isLoading = false, this.photoUrl, this.error});

  PhotoUploadState copyWith({
    bool? isLoading,
    String? photoUrl,
    String? error,
    bool clearError = false,
    bool clearPhotoUrl = false,
  }) {
    return PhotoUploadState(
      isLoading: isLoading ?? this.isLoading,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Notifier untuk manage photo upload state
class PhotoUploadNotifier extends Notifier<PhotoUploadState> {
  @override
  PhotoUploadState build() {
    return const PhotoUploadState();
  }

  PhotoService get _photoService => ref.read(photoServiceProvider);

  /// Upload photo to Supabase
  Future<String?> uploadPhoto({
    required File photoFile,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final photoUrl = await _photoService.uploadProfilePhoto(
        photoFile: photoFile,
        userId: userId,
      );

      state = state.copyWith(isLoading: false, photoUrl: photoUrl);

      return photoUrl;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Delete old profile photo
  Future<void> deletePhoto({required String photoUrl}) async {
    try {
      await _photoService.deleteProfilePhoto(photoUrl: photoUrl);
    } catch (e) {
      debugPrint('[PhotoProvider] Delete photo error: $e');
    }
  }

  /// Clear error
  void clearError() => state = state.copyWith(clearError: true);
}

// Riverpod Provider
final photoUploadProvider =
    NotifierProvider<PhotoUploadNotifier, PhotoUploadState>(
      PhotoUploadNotifier.new,
    );
