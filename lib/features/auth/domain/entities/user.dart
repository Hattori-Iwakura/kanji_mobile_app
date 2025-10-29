import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? profileImage;
  final String role;
  final bool isTwoFactorEnabled;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    required this.role,
    required this.isTwoFactorEnabled,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profileImage,
    role,
    isTwoFactorEnabled,
  ];
}
