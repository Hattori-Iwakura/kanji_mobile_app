import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAuthTokens({
    required String accessToken,
    required String refreshToken,
    String? sessionId,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getSessionId();

  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();

  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheAuthTokens({
    required String accessToken,
    required String refreshToken,
    String? sessionId,
  }) async {
    await secureStorage.write(
      key: AppConstants.keyAccessToken,
      value: accessToken,
    );
    await secureStorage.write(
      key: AppConstants.keyRefreshToken,
      value: refreshToken,
    );
    if (sessionId != null) {
      await secureStorage.write(key: 'session_id', value: sessionId);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: AppConstants.keyAccessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  @override
  Future<String?> getSessionId() async {
    return await secureStorage.read(key: 'session_id');
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await secureStorage.write(key: 'cached_user', value: userJson);
    await secureStorage.write(
      key: AppConstants.keyUserId,
      value: user.id.toString(),
    );
    await secureStorage.write(key: AppConstants.keyUserRole, value: user.role);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = await secureStorage.read(key: 'cached_user');
    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: AppConstants.keyAccessToken);
    await secureStorage.delete(key: AppConstants.keyRefreshToken);
    await secureStorage.delete(key: 'session_id');
    await secureStorage.delete(key: 'cached_user');
    await secureStorage.delete(key: AppConstants.keyUserId);
    await secureStorage.delete(key: AppConstants.keyUserRole);
  }
}
