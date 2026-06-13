// lib/models/auth/login_response.dart

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String email;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['accessToken'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    userId: json['userId'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
  );
}
