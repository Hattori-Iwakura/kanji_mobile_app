import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorage - Wrapper class cho FlutterSecureStorage
///
/// Chức năng:
/// - Lưu trữ sensitive data (JWT token, userId) một cách an toàn
/// - Data được mã hóa trên device storage
/// - iOS: Keychain, Android: EncryptedSharedPreferences
///
/// Sử dụng trong:
/// - AuthLocalDataSource: Lưu/đọc token sau login
/// - AuthRepository: Check auth status khi app khởi động
class SecureStorage {
  final FlutterSecureStorage _storage;

  /// Constructor: Khởi tạo FlutterSecureStorage instance
  SecureStorage() : _storage = const FlutterSecureStorage();

  // Keys để lưu trữ trong secure storage
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  /// Lưu JWT token sau khi login thành công
  /// Token này được gửi kèm trong Authorization header cho các API calls
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Đọc JWT token đã lưu
  /// Returns: token string hoặc null nếu chưa login
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Lưu userId của user hiện tại
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Đọc userId đã lưu
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Xóa tất cả data trong secure storage
  /// Được gọi khi user logout
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// Kiểm tra xem user đã login chưa
  /// Returns: true nếu có token hợp lệ
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
