import 'package:kanji_mobile_app/core/storage/secure_storage.dart';

/// Mock SecureStorage for integration tests
/// flutter_secure_storage doesn't work in test environment,
/// so we use an in-memory implementation
class MockSecureStorage extends SecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String token) async {
    _storage['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _storage['auth_token'];
  }

  @override
  Future<void> saveUserId(String userId) async {
    _storage['user_id'] = userId;
  }

  @override
  Future<String?> getUserId() async {
    return _storage['user_id'];
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> hasToken() async {
    final token = _storage['auth_token'];
    return token != null && token.isNotEmpty;
  }

  void clear() {
    _storage.clear();
  }
}
