import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String account;
  final String email;
  final String? profileImage;
  final bool isFirstLogin;
  final DateTime createdAt;
  final String role;

  const User({
    required this.id,
    required this.account,
    required this.email,
    this.profileImage,
    required this.isFirstLogin,
    required this.createdAt,
    required this.role,
  });

  @override
  List<Object?> get props => [
    id,
    account,
    email,
    profileImage,
    isFirstLogin,
    createdAt,
    role,
  ];

  User copyWith({
    int? id,
    String? account,
    String? email,
    String? profileImage,
    bool? isFirstLogin,
    DateTime? createdAt,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      account: account ?? this.account,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
