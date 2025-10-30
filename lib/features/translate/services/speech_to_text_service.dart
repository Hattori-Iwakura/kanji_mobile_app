import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception('Microphone permission not granted');
      }

      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
        },
        onError: (error) {
          print('Speech recognition error: $error');
          _isListening = false;
        },
      );

      return _isInitialized;
    } catch (e) {
      print('Speech recognition initialization failed: $e');
      return false;
    }
  }

  /// Start listening to speech
  Future<void> startListening({
    required String languageCode,
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Failed to initialize speech recognition');
      }
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      final String locale = _convertLanguageCode(languageCode);

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult || result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        localeId: locale,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );

      _isListening = true;
    } catch (e) {
      print('Start listening failed: $e');
      throw Exception('Failed to start listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      print('Stop listening failed: $e');
    }
  }

  /// Cancel listening
  Future<void> cancel() async {
    try {
      await _speech.cancel();
      _isListening = false;
    } catch (e) {
      print('Cancel listening failed: $e');
    }
  }

  /// Get available locales
  Future<List<stt.LocaleName>> getLocales() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return await _speech.locales();
    } catch (e) {
      print('Get locales failed: $e');
      return [];
    }
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    try {
      return await _speech.initialize();
    } catch (e) {
      return false;
    }
  }

  /// Convert language code to locale ID
  String _convertLanguageCode(String code) {
    switch (code) {
      case 'vi':
        return 'vi_VN';
      case 'en':
        return 'en_US';
      case 'ja':
        return 'ja_JP';
      case 'ko':
        return 'ko_KR';
      case 'zh-cn':
        return 'zh_CN';
      case 'fr':
        return 'fr_FR';
      case 'de':
        return 'de_DE';
      case 'es':
        return 'es_ES';
      case 'it':
        return 'it_IT';
      default:
        return 'en_US';
    }
  }

  /// Dispose resources
  void dispose() {
    _speech.cancel();
  }
}
