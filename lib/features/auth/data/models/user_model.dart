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
      // Backend returns 'name' field, use it as account if available, otherwise use email
      account: (json['name'] as String?) ?? (json['account'] as String?) ?? json['email'] as String,
      email: json['email'] as String,
      // Backend returns 'profileImage' in camelCase
      profileImage: (json['profileImage'] as String?) ?? (json['profile_image'] as String?),
      isFirstLogin: (json['isFirstLogin'] as bool?) ?? (json['is_first_login'] as bool?) ?? false,
      // Backend returns 'createdAt' in camelCase
      createdAt: DateTime.parse((json['createdAt'] as String?) ?? (json['create_at'] as String?) ?? DateTime.now().toIso8601String()),
      role: (json['role'] as String?) ?? 'USER',
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
