import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      print('TTS initialization failed: $e');
    }
  }

  /// Speak text in specified language
  Future<void> speak(String text, String languageCode) async {
    try {
      await initialize();

      // Convert language code to TTS format
      String ttsLanguage = _convertLanguageCode(languageCode);

      await _flutterTts.setLanguage(ttsLanguage);
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak failed: $e');
      throw Exception('Failed to speak text: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS stop failed: $e');
    }
  }

  /// Get available languages
  Future<List<dynamic>> getLanguages() async {
    try {
      await initialize();
      return await _flutterTts.getLanguages ?? [];
    } catch (e) {
      print('Get languages failed: $e');
      return [];
    }
  }

  /// Check if speaking
  Future<bool> get isSpeaking async {
    try {
      final result = await _flutterTts.awaitSpeakCompletion(true);
      return result == 1;
    } catch (e) {
      return false;
    }
  }

  /// Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      print('Set speech rate failed: $e');
    }
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      print('Set volume failed: $e');
    }
  }

  /// Convert language code to TTS format
  String _convertLanguageCode(String code) {
    switch (code) {
      case 'zh-cn':
        return 'zh-CN';
      case 'en':
        return 'en-US';
      case 'ja':
        return 'ja-JP';
      case 'ko':
        return 'ko-KR';
      case 'vi':
        return 'vi-VN';
      case 'fr':
        return 'fr-FR';
      case 'de':
        return 'de-DE';
      case 'es':
        return 'es-ES';
      case 'it':
        return 'it-IT';
      default:
        return code;
    }
  }

  /// Dispose resources
  void dispose() {
    _flutterTts.stop();
  }
}
