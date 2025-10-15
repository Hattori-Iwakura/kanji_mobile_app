import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String account;
  final String email;
  final String? profileImage;
  final bool isFirstLogin;
  final DateTime createAt;

  const User({
    required this.id,
    required this.account,
    required this.email,
    this.profileImage,
    required this.isFirstLogin,
    required this.createAt,
  });

  @override
  List<Object?> get props => [
    id,
    account,
    email,
    profileImage,
    isFirstLogin,
    createAt,
  ];
}
