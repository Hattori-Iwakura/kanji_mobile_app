import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.account,
    required super.email,
    super.profileImage,
    required super.isFirstLogin,
    required super.createAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      account: json['account'] as String,
      email: json['email'] as String,
      profileImage: json['profile_image'] as String?,
      isFirstLogin:
          json['is_first_login'] as bool? ?? false, // Default to false if null
      createAt: json['create_at'] != null
          ? DateTime.parse(json['create_at'] as String)
          : DateTime.now(), // Default to now if null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'email': email,
      'profile_image': profileImage,
      'is_first_login': isFirstLogin,
      'create_at': createAt.toIso8601String(),
    };
  }
}
