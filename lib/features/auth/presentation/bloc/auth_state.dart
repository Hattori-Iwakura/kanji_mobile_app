import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LoginSuccess extends AuthState {
  final User user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class RegisterSuccess extends AuthState {
  final User user;

  const RegisterSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class ProfileLoaded extends AuthState {
  final User user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends AuthState {
  final User user;

  const ProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

class ForgotPasswordSuccess extends AuthState {
  const ForgotPasswordSuccess();
}

class ResetPasswordSuccess extends AuthState {
  const ResetPasswordSuccess();
}
