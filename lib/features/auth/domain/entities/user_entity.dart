import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, username, avatarUrl, role, createdAt];

  @override
  String toString() =>
      'UserEntity(id: $id, email: $email, username: $username)';
}
