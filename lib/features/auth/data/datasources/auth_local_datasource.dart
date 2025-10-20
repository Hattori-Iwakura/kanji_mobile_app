import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> hasValidToken();
  Future<int?> getUserIdFromToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      // Check if token is expired
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      // Invalid token format
      return false;
    }
  }

  @override
  Future<int?> getUserIdFromToken() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] as int?;
    } catch (e) {
      return null;
    }
  }
}
