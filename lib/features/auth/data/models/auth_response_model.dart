import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponse {
  const AuthResponseModel({
    required super.accessToken,
    super.refreshToken,
    super.sessionId,
    required super.user,
    required super.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      sessionId: json['sessionId'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'sessionId': sessionId,
      'user': (user as UserModel).toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
