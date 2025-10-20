import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_flutter/features/kanji_list/models/kanji_list_exception.dart';

void main() {
  group('KanjiListException Tests', () {
    test('should create exception with message', () {
      const message = 'Failed to load kanji list';
      final exception = KanjiListException(message);

      expect(exception.message, message);
      expect(exception.toString(), 'KanjiListException: $message');
    });

    test('should create exception for different error types', () {
      const notFoundMessage = 'Kanji list not found';
      const forbiddenMessage = 'Cannot delete system list';
      const duplicateMessage = 'Kanji already in list';

      final notFound = KanjiListException(notFoundMessage);
      final forbidden = KanjiListException(forbiddenMessage);
      final duplicate = KanjiListException(duplicateMessage);

      expect(notFound.message, notFoundMessage);
      expect(forbidden.message, forbiddenMessage);
      expect(duplicate.message, duplicateMessage);
    });

    test('should have proper toString representation', () {
      final exception = KanjiListException('Test error');

      expect(exception.toString(), 'KanjiListException: Test error');
    });
  });
}
