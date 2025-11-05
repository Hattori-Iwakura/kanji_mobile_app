import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/features/flashcard/data/models/active_session_model.dart';
import 'package:kanji_mobile_app/features/flashcard/data/models/study_session_model.dart';
import 'package:kanji_mobile_app/features/flashcard/domain/entities/review_type.dart';

void main() {
  group('Type Casting Tests', () {
    group('ReviewType Enum Tests', () {
      test('should parse string to ReviewType correctly', () {
        expect(ReviewType.fromString('ALL'), ReviewType.all);
        expect(ReviewType.fromString('NEW_ONLY'), ReviewType.newOnly);
        expect(ReviewType.fromString('DUE_ONLY'), ReviewType.dueOnly);
      });

      test('should convert ReviewType to string value correctly', () {
        expect(ReviewType.all.value, 'ALL');
        expect(ReviewType.newOnly.value, 'NEW_ONLY');
        expect(ReviewType.dueOnly.value, 'DUE_ONLY');
      });

      test('should have correct label and description', () {
        expect(ReviewType.all.label, 'All Cards');
        expect(ReviewType.newOnly.label, 'New Cards Only');
        expect(ReviewType.dueOnly.label, 'Due Cards Only');

        expect(ReviewType.all.description, isNotEmpty);
        expect(ReviewType.newOnly.description, isNotEmpty);
        expect(ReviewType.dueOnly.description, isNotEmpty);
      });
    });

    group('ActiveSessionModel Type Casting Tests', () {
      test('should parse JSON with integer values correctly', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 80.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);

        expect(model.sessionId, isA<int>());
        expect(model.sessionId, 1);
        expect(model.deckId, isA<int>());
        expect(model.deckId, 2);
        expect(model.totalCards, isA<int>());
        expect(model.totalCards, 10);
        expect(model.cardsReviewed, isA<int>());
        expect(model.cardsReviewed, 5);
        expect(model.cardsRemaining, isA<int>());
        expect(model.cardsRemaining, 5);
        expect(model.accuracy, isA<double>());
        expect(model.accuracy, 80.0);
        expect(model.startedAt, isA<DateTime>());
      });

      test('should handle JSON with double values as integers', () {
        final json = {
          'sessionId': 1.0,
          'deckId': 2.0,
          'totalCards': 10.0,
          'cardsReviewed': 5.0,
          'cardsRemaining': 5.0,
          'accuracy': 80.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        expect(() => ActiveSessionModel.fromJson(json), returnsNormally);

        final model = ActiveSessionModel.fromJson(json);
        expect(model.sessionId, isA<int>());
        expect(model.deckId, isA<int>());
        expect(model.totalCards, isA<int>());
      });

      test('should handle accuracy as integer from API', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 80, // Integer instead of double
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);
        expect(model.accuracy, isA<double>());
        expect(model.accuracy, 80.0);
      });

      test('should calculate progressPercentage correctly', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 3,
          'cardsRemaining': 7,
          'accuracy': 100.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);
        expect(model.progressPercentage, isA<double>());
        expect(model.progressPercentage, 30.0);
      });

      test('should handle zero totalCards in progressPercentage', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 0,
          'cardsReviewed': 0,
          'cardsRemaining': 0,
          'accuracy': 0.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);
        expect(model.progressPercentage, 0.0);
      });

      test('should convert to JSON correctly', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 80.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);
        final backToJson = model.toJson();

        expect(backToJson['sessionId'], 1);
        expect(backToJson['deckId'], 2);
        expect(backToJson['totalCards'], 10);
        expect(backToJson['cardsReviewed'], 5);
        expect(backToJson['cardsRemaining'], 5);
        expect(backToJson['accuracy'], 80.0);
        expect(backToJson['startedAt'], isA<String>());
      });
    });

    group('StudySessionModel Type Casting Tests', () {
      test('should parse session start response correctly', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'deckName': 'Test Deck',
          'totalCards': 15,
          'newCards': 10,
          'reviewCards': 5,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = StudySessionModel.fromJson(json);

        expect(model.sessionId, isA<int>());
        expect(model.sessionId, 1);
        expect(model.deckId, isA<int>());
        expect(model.deckId, 2);
        expect(model.deckName, isA<String>());
        expect(model.deckName, 'Test Deck');
        expect(model.totalCards, isA<int>());
        expect(model.totalCards, 15);
        expect(model.newCards, isA<int>());
        expect(model.newCards, 10);
        expect(model.reviewCards, isA<int>());
        expect(model.reviewCards, 5);
        expect(model.startedAt, isA<DateTime>());
      });

      test('should handle numeric fields as doubles from API', () {
        final json = {
          'sessionId': 1.0,
          'deckId': 2.0,
          'deckName': 'Test Deck',
          'totalCards': 15.0,
          'newCards': 10.0,
          'reviewCards': 5.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        expect(() => StudySessionModel.fromJson(json), returnsNormally);

        final model = StudySessionModel.fromJson(json);
        expect(model.sessionId, isA<int>());
        expect(model.totalCards, isA<int>());
        expect(model.newCards, isA<int>());
      });

      test('should parse DateTime from ISO 8601 string', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'deckName': 'Test Deck',
          'totalCards': 10,
          'newCards': 5,
          'reviewCards': 5,
          'startedAt': '2024-01-15T14:30:45.123Z',
        };

        final model = StudySessionModel.fromJson(json);
        final startedAt = model.startedAt;

        expect(startedAt, isA<DateTime>());
        expect(startedAt.year, 2024);
        expect(startedAt.month, 1);
        expect(startedAt.day, 15);
        expect(startedAt.hour, 14);
        expect(startedAt.minute, 30);
      });

      test('should convert to JSON correctly', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'deckName': 'Test Deck',
          'totalCards': 10,
          'newCards': 5,
          'reviewCards': 5,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = StudySessionModel.fromJson(json);
        final backToJson = model.toJson();

        expect(backToJson['sessionId'], 1);
        expect(backToJson['deckId'], 2);
        expect(backToJson['deckName'], 'Test Deck');
        expect(backToJson['totalCards'], 10);
        expect(backToJson['newCards'], 5);
        expect(backToJson['reviewCards'], 5);
        expect(backToJson['startedAt'], isA<String>());
      });
    });

    group('Edge Cases Tests', () {
      test('should handle null values gracefully in optional fields', () {
        // Test that required fields throw when null
        expect(
          () => ActiveSessionModel.fromJson({
            'deckId': 1,
            'totalCards': 10,
            'cardsReviewed': 5,
            'cardsRemaining': 5,
            'accuracy': 80.0,
            'startedAt': '2024-01-01T10:00:00.000Z',
            // Missing sessionId
          }),
          throwsA(anything),
        );
      });

      test('should handle very large numbers', () {
        final json = {
          'sessionId': 999999999,
          'deckId': 888888888,
          'totalCards': 1000000,
          'cardsReviewed': 500000,
          'cardsRemaining': 500000,
          'accuracy': 99.9999,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);
        expect(model.sessionId, 999999999);
        expect(model.deckId, 888888888);
        expect(model.totalCards, 1000000);
      });

      test('should handle zero values', () {
        final json = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 0,
          'cardsReviewed': 0,
          'cardsRemaining': 0,
          'accuracy': 0.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);
        expect(model.totalCards, 0);
        expect(model.cardsReviewed, 0);
        expect(model.accuracy, 0.0);
      });

      test('should handle accuracy edge values', () {
        final json1 = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 0.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model1 = ActiveSessionModel.fromJson(json1);
        expect(model1.accuracy, 0.0);

        final json2 = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 100.0,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model2 = ActiveSessionModel.fromJson(json2);
        expect(model2.accuracy, 100.0);
      });

      test('should handle DateTime with different formats', () {
        // ISO 8601 with milliseconds
        final json1 = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 80.0,
          'startedAt': '2024-01-01T10:00:00.123Z',
        };
        expect(() => ActiveSessionModel.fromJson(json1), returnsNormally);

        // ISO 8601 without milliseconds
        final json2 = {
          'sessionId': 1,
          'deckId': 2,
          'totalCards': 10,
          'cardsReviewed': 5,
          'cardsRemaining': 5,
          'accuracy': 80.0,
          'startedAt': '2024-01-01T10:00:00Z',
        };
        expect(() => ActiveSessionModel.fromJson(json2), returnsNormally);
      });
    });

    group('Type Conversion Tests', () {
      test('should convert num to int correctly', () {
        final json = {
          'sessionId': 1.0, // double
          'deckId': 2, // int
          'totalCards': 10.0,
          'cardsReviewed': 5,
          'cardsRemaining': 5.0,
          'accuracy': 80,
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        final model = ActiveSessionModel.fromJson(json);

        // All should be converted to appropriate types
        expect(model.sessionId, isA<int>());
        expect(model.deckId, isA<int>());
        expect(model.totalCards, isA<int>());
        expect(model.cardsReviewed, isA<int>());
        expect(model.cardsRemaining, isA<int>());
        expect(model.accuracy, isA<double>());
      });

      test('should handle string numbers if API sends them', () {
        // This test checks if our models can handle unexpected string numbers
        final json = {
          'sessionId': '1',
          'deckId': '2',
          'totalCards': '10',
          'cardsReviewed': '5',
          'cardsRemaining': '5',
          'accuracy': '80.0',
          'startedAt': '2024-01-01T10:00:00.000Z',
        };

        // This should throw because we expect numbers, not strings
        expect(() => ActiveSessionModel.fromJson(json), throwsA(anything));
      });
    });
  });
}
