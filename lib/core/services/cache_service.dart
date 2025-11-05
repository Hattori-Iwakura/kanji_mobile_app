import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// CacheService - Service để cache responses từ External APIs
///
/// Tại sao cần cache?
/// - Giảm số lượng API calls đến external APIs (KanjiAlive, Jisho, KanjiVG)
/// - Tiết kiệm bandwidth và tăng tốc độ load
/// - Tránh hit API rate limit
///
/// Cơ chế hoạt động:
/// 1. Khi gọi external API lần đầu -> Lưu response vào cache với expiration time
/// 2. Lần sau khi gọi -> Check cache trước, nếu còn valid thì return cached data
/// 3. Nếu cache expired -> Xóa cache cũ và gọi API mới
///
/// Sử dụng trong: KanjiAliveService, JishoService, KanjiVGService
class CacheService {
  static const String _prefix = 'cache_'; // Prefix để phân biệt cache keys
  static const Duration _defaultCacheDuration = Duration(
    days: 7,
  ); // Cache 7 ngày

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  /// Lưu Map data vào cache với expiration time
  ///
  /// Params:
  /// - key: Unique key để identify cache (vd: 'kanjialive_日')
  /// - data: JSON data cần cache
  /// - duration: Thời gian cache valid (default 7 ngày)
  ///
  /// Cache structure: { 'data': {...}, 'expiration': timestamp }
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

  /// Đọc Map data từ cache
  ///
  /// Returns:
  /// - Map<String, dynamic> nếu cache tồn tại và chưa expired
  /// - null nếu không có cache hoặc đã expired
  ///
  /// Tự động xóa cache nếu expired hoặc corrupted
  Future<Map<String, dynamic>?> get(String key) async {
    final cacheKey = _prefix + key;
    final cacheString = _prefs.getString(cacheKey);

    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      // Check nếu cache đã hết hạn
      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        await remove(key); // Xóa cache cũ
        return null;
      }

      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      // Nếu parse lỗi (cache corrupted) -> Xóa cache
      await remove(key);
      return null;
    }
  }

  /// Lưu List data vào cache
  /// Dùng cho endpoints trả về array (vd: search results, list items)
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

  /// Đọc List data từ cache
  Future<List<Map<String, dynamic>>?> getList(String key) async {
    final cacheKey = _prefix + key;
    final cacheString = _prefs.getString(cacheKey);

    if (cacheString == null) return null;

    try {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      // Check nếu cache đã hết hạn
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

  /// Xóa một cache item cụ thể
  Future<void> remove(String key) async {
    final cacheKey = _prefix + key;
    await _prefs.remove(cacheKey);
  }

  /// Xóa tất cả cache items
  /// Hữu ích khi cần refresh toàn bộ cached data
  Future<void> clearAll() async {
    final keys = _prefs.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_prefix));

    for (final key in cacheKeys) {
      await _prefs.remove(key);
    }
  }

  /// Kiểm tra cache có tồn tại và còn valid không
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Lấy thời gian expiration của cache
  /// Dùng để hiển thị "cache expires in X hours"
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
