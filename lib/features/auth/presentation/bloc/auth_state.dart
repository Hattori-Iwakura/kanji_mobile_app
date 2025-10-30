import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/two_factor_setup.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// 2FA States
class TwoFactorRequired extends AuthState {
  final String email;
  final String password;

  const TwoFactorRequired(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class TwoFactorSetupSuccess extends AuthState {
  final TwoFactorSetup setup;

  const TwoFactorSetupSuccess(this.setup);

  @override
  List<Object?> get props => [setup];
}

class TwoFactorEnabled extends AuthState {
  final User user;

  const TwoFactorEnabled(this.user);

  @override
  List<Object?> get props => [user];
}

class TwoFactorDisabled extends AuthState {
  final User user;

  const TwoFactorDisabled(this.user);

  @override
  List<Object?> get props => [user];
}

class EmailOTPSent extends AuthState {}

// Password Reset States
class ForgotPasswordSuccess extends AuthState {}

class ResetPasswordSuccess extends AuthState {}

class PasswordChangeSuccess extends AuthState {}
