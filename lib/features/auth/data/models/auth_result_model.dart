import '../../domain/entities/auth_result.dart';
import 'user_model.dart';

class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    super.sessionId,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?, // Optional
      sessionId: json['sessionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'sessionId': sessionId,
    };
  }

  AuthResult toEntity() {
    return AuthResult(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionId: sessionId,
    );
  }
}
