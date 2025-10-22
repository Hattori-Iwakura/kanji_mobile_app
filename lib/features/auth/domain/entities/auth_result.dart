import 'package:equatable/equatable.dart';
import 'user.dart';

class AuthResult extends Equatable {
  final User user;
  final String accessToken;
  final String? refreshToken; // Optional - backend may not return it
  final String? sessionId;

  const AuthResult({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.sessionId,
  });

  @override
  List<Object?> get props => [user, accessToken, refreshToken, sessionId];
}
