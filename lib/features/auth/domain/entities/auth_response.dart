import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String? sessionId;
  final User user;
  final DateTime expiresAt;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.sessionId,
    required this.user,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    sessionId,
    user,
    expiresAt,
  ];
}
