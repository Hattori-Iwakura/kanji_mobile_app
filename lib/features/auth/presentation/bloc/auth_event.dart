import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String account;
  final String password;

  const LoginEvent({required this.account, required this.password});

  @override
  List<Object?> get props => [account, password];
}

class RegisterEvent extends AuthEvent {
  final String account;
  final String email;
  final String password;

  const RegisterEvent({
    required this.account,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [account, email, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class GetProfileEvent extends AuthEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? profileImage;

  const UpdateProfileEvent({this.name, this.profileImage});

  @override
  List<Object?> get props => [name, profileImage];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordEvent({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}
