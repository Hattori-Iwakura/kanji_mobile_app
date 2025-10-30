import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_result.dart';

class TranslationHistoryService {
  static const String _historyKey = 'translation_history';
  static const int _maxHistoryItems = 50;

  final SharedPreferences _prefs;

  TranslationHistoryService(this._prefs);

  /// Get translation history
  List<TranslationResult> getHistory() {
    try {
      final String? historyJson = _prefs.getString(_historyKey);
      if (historyJson == null) return [];

      final List<dynamic> historyList = jsonDecode(historyJson);
      return historyList
          .map((json) => TranslationResult.fromJson(json))
          .toList()
          .reversed
          .toList(); // Most recent first
    } catch (e) {
      print('Error loading translation history: $e');
      return [];
    }
  }

  /// Add translation to history
  Future<bool> addToHistory(TranslationResult result) async {
    try {
      final history = getHistory();

      // Add new item at the beginning
      history.insert(0, result);

      // Keep only last N items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      final historyJson = jsonEncode(history.map((r) => r.toJson()).toList());

      return await _prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Error saving translation to history: $e');
      return false;
    }
  }

  /// Clear all history
  Future<bool> clearHistory() async {
    try {
      return await _prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  /// Remove specific item from history
  Future<bool> removeFromHistory(int index) async {
    try {
      final history = getHistory();
      if (index < 0 || index >= history.length) return false;

      history.removeAt(index);

      final historyJson = jsonEncode(history.map((r) => r.toJson()).toList());

      return await _prefs.setString(_historyKey, historyJson);
    } catch (e) {
      print('Error removing from history: $e');
      return false;
    }
  }

  /// Search history
  List<TranslationResult> searchHistory(String query) {
    try {
      final history = getHistory();
      final lowerQuery = query.toLowerCase();

      return history.where((result) {
        return result.originalText.toLowerCase().contains(lowerQuery) ||
            result.translatedText.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching history: $e');
      return [];
    }
  }
}
