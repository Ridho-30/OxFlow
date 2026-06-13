// lib/services/auth_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api/api_client.dart';
import 'api/api_endpoints.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';

class AuthService {
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  AuthService(this._apiClient);

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<LoginResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    // Backend wraps data under `data` key in some responses; handle both
    final payload = response['data'] ?? response;
    final loginResponse = LoginResponse.fromJson(payload);

    await _secureStorage.write(
        key: 'access_token', value: loginResponse.accessToken);
    await _secureStorage.write(
        key: 'refresh_token', value: loginResponse.refreshToken);
    await _secureStorage.write(key: 'user_name', value: loginResponse.name);
    await _secureStorage.write(key: 'user_email', value: loginResponse.email);
    await _secureStorage.write(key: 'user_id', value: loginResponse.userId);

    return loginResponse;
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final request = RegisterRequest(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    final payload = response['data'] ?? response;
    final loginResponse = LoginResponse.fromJson(payload);

    await _secureStorage.write(
        key: 'access_token', value: loginResponse.accessToken);
    await _secureStorage.write(
        key: 'refresh_token', value: loginResponse.refreshToken);
    await _secureStorage.write(key: 'user_name', value: loginResponse.name);
    await _secureStorage.write(key: 'user_email', value: loginResponse.email);
    await _secureStorage.write(key: 'user_id', value: loginResponse.userId);

    return loginResponse;
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  // ── Reset Password (via email token) ──────────────────────────────────────
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
  }

  // ── Change Password (authenticated — PATCH /api/auth/change-password) ──────
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiClient.patch(
      ApiEndpoints.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Even if server call fails, clear local tokens
    } finally {
      await _clearStorage();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<String?> getAccessToken() =>
      _secureStorage.read(key: 'access_token');

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String?>> getCachedUserInfo() async {
    return {
      'name': await _secureStorage.read(key: 'user_name'),
      'email': await _secureStorage.read(key: 'user_email'),
      'userId': await _secureStorage.read(key: 'user_id'),
    };
  }

  Future<void> _clearStorage() async {
    await _secureStorage.deleteAll();
  }
}
