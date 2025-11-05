import 'package:equatable/equatable.dart';

/// User Entity - Pure business object trong Domain layer
///
/// Đặc điểm của Entity:
/// - Không phụ thuộc vào bất kỳ framework nào (pure Dart)
/// - Không có logic serialize/deserialize (không có fromJson/toJson)
/// - Chỉ chứa business logic thuần túy
/// - Immutable (tất cả fields là final)
///
/// Extends Equatable để:
/// - So sánh 2 User objects dựa trên values thay vì references
/// - Giúp BLoC state comparison hoạt động đúng
///
/// Sử dụng trong:
/// - Use cases (input/output)
/// - BLoC states (để quản lý user state)
/// - UI hiển thị thông tin user
class User extends Equatable {
  final int id;
  final String email;
  final String name;
  final String? profileImage; // Nullable - user có thể không có avatar
  final String role; // 'user' hoặc 'admin'
  final bool isTwoFactorEnabled; // Đã bật 2FA chưa

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    required this.role,
    required this.isTwoFactorEnabled,
  });

  /// Equatable props - Các fields dùng để so sánh 2 User objects
  /// Nếu tất cả props giống nhau -> 2 Users bằng nhau
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
