import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String? twoFactorCode;

  const LoginEvent(this.email, this.password, {this.twoFactorCode});

  @override
  List<Object?> get props => [email, password, twoFactorCode];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterEvent(this.email, this.password, this.name);

  @override
  List<Object?> get props => [email, password, name];
}

class LogoutEvent extends AuthEvent {}

class GetProfileEvent extends AuthEvent {}

// 2FA Events
class Setup2FAEvent extends AuthEvent {}

class Enable2FAEvent extends AuthEvent {
  final String code;

  const Enable2FAEvent(this.code);

  @override
  List<Object?> get props => [code];
}

class Disable2FAEvent extends AuthEvent {
  final String password;
  final String code;

  const Disable2FAEvent(this.password, this.code);

  @override
  List<Object?> get props => [password, code];
}

class SendEmailOTPEvent extends AuthEvent {}

// Password Reset Events
class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent(this.token, this.newPassword);

  @override
  List<Object?> get props => [token, newPassword];
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
