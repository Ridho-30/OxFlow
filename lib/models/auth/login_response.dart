// lib/models/auth/login_response.dart

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String email;
  final String profilePicture;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.email,
    required this.profilePicture,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return LoginResponse(
      accessToken: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      userId: userJson != null
          ? (userJson['user_id'] ?? userJson['userId'] ?? '')
          : (json['userId'] ?? ''),
      name: userJson != null ? (userJson['name'] ?? '') : (json['name'] ?? ''),
      email: userJson != null ? (userJson['email'] ?? '') : (json['email'] ?? ''),
      profilePicture: userJson != null
          ? (userJson['profile_picture'] ?? userJson['profilePicture'] ?? '')
          : (json['profilePicture'] ?? json['profile_picture'] ?? ''),
    );
  }
}
