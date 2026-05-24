class UserModel {
  final int id;
  final String firebaseUid;
  final String email;
  final String name;
  final String role;
  final bool emailVerified;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int? ?? json['ID'] as int? ?? 0,
    firebaseUid: json['firebase_uid'] as String? ?? '',
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? '',
    emailVerified: json['email_verified'] as bool? ?? false,
    createdAt: json['created_at'] as String? ?? '',
  );
}

class AuthResponseModel {
  final bool success;
  final String message;
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserModel? user;

  const AuthResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final userJson = data['user'];

    return AuthResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      accessToken: data['access_token'] as String? ?? '',
      tokenType: data['token_type'] as String? ?? 'Bearer',
      expiresIn: data['expires_in'] as int? ?? 0,
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : null,
    );
  }
}
