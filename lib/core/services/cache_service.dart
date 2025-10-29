import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching external API responses to reduce API calls
class CacheService {
  static const String _prefix = 'cache_';
  static const Duration _defaultCacheDuration = Duration(days: 7);

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Save data to cache with expiration
  Future<void> save({
    required String key,
    required Map<String, dynamic> data,
    Duration? duration,
  }) async {
    final cacheKey = _prefix + key;
    final expiration = DateTime.now()
        .add(duration ?? _defaultCacheDuration)
        .millisecondsSinceEpoch;

    final cacheData = {'data': data, 'expiration': expiration};

    await _prefs.setString(cacheKey, jsonEncode(cacheData));
  }

  /// Get data from cache if not expired
  Future<Map<String, dynamic>?> get(String key) async {
    final cacheKey = _prefix + key;
    final cacheString = _prefs.getString(cacheKey);

    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      // Check if cache has expired
      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        await remove(key);
        return null;
      }

      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      // If parsing fails, remove corrupted cache
      await remove(key);
      return null;
    }
  }

  /// Save list data to cache
  Future<void> saveList({
    required String key,
    required List<Map<String, dynamic>> data,
    Duration? duration,
  }) async {
    final cacheKey = _prefix + key;
    final expiration = DateTime.now()
        .add(duration ?? _defaultCacheDuration)
        .millisecondsSinceEpoch;

    final cacheData = {'data': data, 'expiration': expiration};

    await _prefs.setString(cacheKey, jsonEncode(cacheData));
  }

  /// Get list data from cache
  Future<List<Map<String, dynamic>>?> getList(String key) async {
    final cacheKey = _prefix + key;
    final cacheString = _prefs.getString(cacheKey);

    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      // Check if cache has expired
      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        await remove(key);
        return null;
      }

      final data = cacheData['data'] as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      await remove(key);
      return null;
    }
  }

  /// Remove specific cache
  Future<void> remove(String key) async {
    final cacheKey = _prefix + key;
    await _prefs.remove(cacheKey);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_prefix));

    for (final key in cacheKeys) {
      await _prefs.remove(key);
    }
  }

  /// Check if cache exists and is valid
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Get cache expiration time
  Future<DateTime?> getExpiration(String key) async {
    final cacheKey = _prefix + key;
    final cacheString = _prefs.getString(cacheKey);

    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;
      return DateTime.fromMillisecondsSinceEpoch(expiration);
    } catch (e) {
      return null;
    }
  }
}
