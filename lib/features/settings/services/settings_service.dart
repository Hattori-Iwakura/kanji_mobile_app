import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Load settings from local storage
  AppSettings loadSettings() {
    try {
      final String? settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return AppSettings.fromJson(json);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    return const AppSettings(); // Return default settings
  }

  /// Save settings to local storage
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final String settingsJson = jsonEncode(settings.toJson());
      return await _prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Clear all settings
  Future<bool> clearSettings() async {
    try {
      return await _prefs.remove(_settingsKey);
    } catch (e) {
      print('Error clearing settings: $e');
      return false;
    }
  }
}
