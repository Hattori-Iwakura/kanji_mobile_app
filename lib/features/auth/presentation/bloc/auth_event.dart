import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LoginRequested extends AuthEvent {
  final String account;
  final String password;

  const LoginRequested(this.account, this.password);

  @override
  List<Object?> get props => [account, password];
}

class RefreshTokenRequested extends AuthEvent {
  const RefreshTokenRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
