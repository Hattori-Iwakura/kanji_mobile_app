import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearAuth();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.saveToken(token);
    } catch (e) {
      throw CacheException('Failed to save token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.getToken();
    } catch (e) {
      throw CacheException('Failed to get token');
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    try {
      await secureStorage.saveUserId(userId);
    } catch (e) {
      throw CacheException('Failed to save user ID');
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await secureStorage.getUserId();
    } catch (e) {
      throw CacheException('Failed to get user ID');
    }
  }

  @override
  Future<void> clearAuth() async {
    try {
      await secureStorage.deleteAll();
    } catch (e) {
      throw CacheException('Failed to clear auth');
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      return await secureStorage.hasToken();
    } catch (e) {
      return false;
    }
  }
}
