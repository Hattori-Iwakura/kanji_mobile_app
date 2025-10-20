import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/kanji/models/kanji_exception.dart';

void main() {
  group('KanjiException Tests', () {
    test('should create exception with message', () {
      const message = 'Failed to load kanji';
      final exception = KanjiException(message);

      expect(exception.message, message);
    });

    test('should return message in toString', () {
      const message = 'Network error';
      final exception = KanjiException(message);

      expect(exception.toString(), message);
    });

    test('should handle empty message', () {
      final exception = KanjiException('');

      expect(exception.message, '');
      expect(exception.toString(), '');
    });

    test('should handle special characters in message', () {
      const message = 'Error: 漢字 not found (404)';
      final exception = KanjiException(message);

      expect(exception.message, message);
      expect(exception.toString(), message);
    });
  });
}
