import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/auth/data/models/user_model.dart';
import 'package:kanji_mobile_v1/features/flashcard/data/models/flashcard_deck_new_model.dart';

void main() {
  final tFlashcardDeckModel = FlashcardDeckNewModel(
    id: 1,
    name: 'JLPT N5 Kanji',
    description: 'Basic kanji for N5 level',
    userId: 1,
    isPublic: false,
    createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    updatedAt: DateTime.parse('2024-01-15T00:00:00.000Z'),
    cards: const [],
    user: UserModel(
      id: 1,
      account: 'testuser',
      email: 'test@example.com',
      isFirstLogin: false,
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      role: 'USER',
    ),
  );

  group('FlashcardDeckNewModel', () {
    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'name': 'JLPT N5 Kanji',
          'description': 'Basic kanji for N5 level',
          'userId': 1,
          'isPublic': false,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-15T00:00:00.000Z',
          'cards': [],
          'user': {
            'id': 1,
            'email': 'test@example.com',
            'name': 'testuser',
            'isFirstLogin': false,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'role': 'USER',
          },
        };

        // act
        final result = FlashcardDeckNewModel.fromJson(jsonMap);

        // assert
        expect(result.id, 1);
        expect(result.name, 'JLPT N5 Kanji');
        expect(result.description, 'Basic kanji for N5 level');
        expect(result.userId, 1);
        expect(result.isPublic, false);
      });

      test('should return model without description', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'name': 'JLPT N5 Kanji',
          'userId': 1,
          'isPublic': false,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-15T00:00:00.000Z',
          'cards': [],
          'user': {
            'id': 1,
            'email': 'test@example.com',
            'name': 'testuser',
            'isFirstLogin': false,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'role': 'USER',
          },
        };

        // act
        final result = FlashcardDeckNewModel.fromJson(jsonMap);

        // assert
        expect(result.description, isNull);
      });

      test('should handle public deck', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'name': 'Public Deck',
          'userId': 1,
          'isPublic': true,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-15T00:00:00.000Z',
          'cards': [],
          'user': {
            'id': 1,
            'email': 'test@example.com',
            'name': 'testuser',
            'isFirstLogin': false,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'role': 'USER',
          },
        };

        // act
        final result = FlashcardDeckNewModel.fromJson(jsonMap);

        // assert
        expect(result.isPublic, true);
      });
    });

    group('toJson', () {
      test('should return JSON map with proper data', () {
        // act
        final result = tFlashcardDeckModel.toJson();

        // assert
        expect(result['id'], 1);
        expect(result['name'], 'JLPT N5 Kanji');
        expect(result['description'], 'Basic kanji for N5 level');
        expect(result['userId'], 1);
        expect(result['isPublic'], false);
        expect(result['createdAt'], '2024-01-01T00:00:00.000Z');
        expect(result['updatedAt'], '2024-01-15T00:00:00.000Z');
        expect(result['cards'], []);
      });

      test('should omit description if null', () {
        // arrange
        final model = FlashcardDeckNewModel(
          id: 1,
          name: 'Deck',
          description: null,
          userId: 1,
          isPublic: false,
          createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
          cards: const [],
          user: UserModel(
            id: 1,
            account: 'testuser',
            email: 'test@example.com',
            isFirstLogin: false,
            createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
            role: 'USER',
          ),
        );

        // act
        final result = model.toJson();

        // assert
        expect(result.containsKey('description'), false);
      });
    });

    test('should return correct totalCards', () {
      // assert
      expect(tFlashcardDeckModel.totalCards, 0);
    });
  });
}
