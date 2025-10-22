import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.account,
    required super.email,
    super.profileImage,
    required super.isFirstLogin,
    required super.createdAt,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      account: json['account'] as String,
      email: json['email'] as String,
      profileImage: json['profile_image'] as String?,
      isFirstLogin: json['is_first_login'] as bool? ?? false,
      createdAt: DateTime.parse(json['create_at'] as String),
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'email': email,
      'profile_image': profileImage,
      'is_first_login': isFirstLogin,
      'create_at': createdAt.toIso8601String(),
      'role': role,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      account: user.account,
      email: user.email,
      profileImage: user.profileImage,
      isFirstLogin: user.isFirstLogin,
      createdAt: user.createdAt,
      role: user.role,
    );
  }

  User toEntity() {
    return User(
      id: id,
      account: account,
      email: email,
      profileImage: profileImage,
      isFirstLogin: isFirstLogin,
      createdAt: createdAt,
      role: role,
    );
  }
}
