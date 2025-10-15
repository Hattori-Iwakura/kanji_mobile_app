import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/auth_response_model.dart';
import 'dart:convert';

class AuthService {
  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keySessionId = 'session_id';
  static const _keyAuthResponse = 'auth_response';

  AuthService(this._storage);

  // Save auth data
  Future<void> saveAuthData(AuthResponseModel authResponse) async {
    await _storage.write(key: _keyAccessToken, value: authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await _storage.write(
        key: _keyRefreshToken,
        value: authResponse.refreshToken,
      );
    }
    if (authResponse.sessionId != null) {
      await _storage.write(key: _keySessionId, value: authResponse.sessionId);
    }
    await _storage.write(
      key: _keyAuthResponse,
      value: jsonEncode(authResponse.toJson()),
    );
  }

  // Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // Get session ID
  Future<String?> getSessionId() async {
    return await _storage.read(key: _keySessionId);
  }

  // Get full auth response
  Future<AuthResponseModel?> getAuthResponse() async {
    final data = await _storage.read(key: _keyAuthResponse);
    if (data != null) {
      return AuthResponseModel.fromJson(jsonDecode(data));
    }
    return null;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keySessionId);
    await _storage.delete(key: _keyAuthResponse);
  }
}
