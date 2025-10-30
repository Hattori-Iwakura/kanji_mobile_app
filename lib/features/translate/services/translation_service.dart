import 'package:translator/translator.dart';
import '../models/translation_result.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  /// Translate text from source language to target language
  Future<TranslationResult> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      // Use 'auto' for auto-detection
      final String fromLang = from == 'auto' ? 'auto' : from;

      final translation = await _translator.translate(
        text,
        from: fromLang,
        to: to,
      );

      return TranslationResult(
        originalText: text,
        translatedText: translation.text,
        sourceLanguage: translation.sourceLanguage.code,
        targetLanguage: to,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }

  /// Detect language of the text
  Future<String> detectLanguage(String text) async {
    try {
      final translation = await _translator.translate(
        text,
        from: 'auto',
        to: 'en',
      );
      return translation.sourceLanguage.code;
    } catch (e) {
      throw Exception('Language detection failed: $e');
    }
  }
}
