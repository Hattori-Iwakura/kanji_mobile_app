import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/flashcard/data/datasources/flashcard_deck_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/flashcard/data/models/flashcard_deck_new_model.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late FlashcardDeckRemoteDataSourceImpl datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = FlashcardDeckRemoteDataSourceImpl(dio: mockDio);
  });

  group('getAllDecks', () {
    final tResponse = {
      'data': [
        {
          'id': 1,
          'name': 'Deck 1',
          'userId': 1,
          'isPublic': false,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
          'cards': [],
          'user': {
            'id': 1,
            'email': 'test@example.com',
            'name': 'testuser',
            'isFirstLogin': false,
            'createdAt': '2024-01-01T00:00:00.000Z',
            'role': 'USER',
          },
        },
      ],
      'total': 1,
      'limit': 10,
      'offset': 0,
    };

    test('should perform GET request to /flashcard-decks', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks'),
        ),
      );

      // act
      await datasource.getAllDecks();

      // assert
      verify(
        () => mockDio.get(
          '/flashcard-decks',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
    });

    test('should return FlashcardDecksResponse when successful', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks'),
        ),
      );

      // act
      final result = await datasource.getAllDecks();

      // assert
      expect(result, isA<FlashcardDecksResponse>());
      expect(result.data.length, 1);
      expect(result.total, 1);
    });

    test('should include query parameters when provided', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          data: tResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks'),
        ),
      );

      // act
      await datasource.getAllDecks(search: 'test', limit: 10, offset: 0);

      // assert
      verify(
        () => mockDio.get(
          '/flashcard-decks',
          queryParameters: {'search': 'test', 'limit': 10, 'offset': 0},
        ),
      ).called(1);
    });

    test('should throw ServerException when DioException occurs', () async {
      // arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/flashcard-decks'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/flashcard-decks'),
          ),
        ),
      );

      // act
      final call = datasource.getAllDecks;

      // assert
      expect(() => call(), throwsA(isA<Exception>()));
    });
  });

  group('getDeckById', () {
    final tDeckJson = {
      'id': 1,
      'name': 'Deck 1',
      'userId': 1,
      'isPublic': false,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
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

    test('should perform GET request to /flashcard-decks/:id', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tDeckJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks/1'),
        ),
      );

      // act
      await datasource.getDeckById(1);

      // assert
      verify(() => mockDio.get('/flashcard-decks/1')).called(1);
    });

    test('should return FlashcardDeckNewModel when successful', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tDeckJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks/1'),
        ),
      );

      // act
      final result = await datasource.getDeckById(1);

      // assert
      expect(result, isA<FlashcardDeckNewModel>());
      expect(result.id, 1);
      expect(result.name, 'Deck 1');
    });
  });

  group('createDeck', () {
    final tDeckJson = {
      'id': 1,
      'name': 'New Deck',
      'description': 'Test description',
      'userId': 1,
      'isPublic': false,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
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

    test('should perform POST request to /flashcard-decks', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tDeckJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/flashcard-decks'),
        ),
      );

      // act
      await datasource.createDeck(
        name: 'New Deck',
        description: 'Test description',
      );

      // assert
      verify(
        () => mockDio.post(
          '/flashcard-decks',
          data: {'name': 'New Deck', 'description': 'Test description'},
        ),
      ).called(1);
    });

    test('should return FlashcardDeckNewModel when successful', () async {
      // arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tDeckJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/flashcard-decks'),
        ),
      );

      // act
      final result = await datasource.createDeck(name: 'New Deck');

      // assert
      expect(result, isA<FlashcardDeckNewModel>());
      expect(result.name, 'New Deck');
    });
  });

  group('updateDeck', () {
    final tDeckJson = {
      'id': 1,
      'name': 'Updated Deck',
      'userId': 1,
      'isPublic': true,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-02T00:00:00.000Z',
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

    test('should perform PUT request to /flashcard-decks/:id', () async {
      // arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tDeckJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks/1'),
        ),
      );

      // act
      await datasource.updateDeck(id: 1, name: 'Updated Deck', isPublic: true);

      // assert
      verify(
        () => mockDio.put(
          '/flashcard-decks/1',
          data: {'name': 'Updated Deck', 'isPublic': true},
        ),
      ).called(1);
    });

    test('should return FlashcardDeckNewModel when successful', () async {
      // arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tDeckJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/flashcard-decks/1'),
        ),
      );

      // act
      final result = await datasource.updateDeck(id: 1, name: 'Updated Deck');

      // assert
      expect(result, isA<FlashcardDeckNewModel>());
      expect(result.name, 'Updated Deck');
    });
  });

  group('deleteDeck', () {
    test('should perform DELETE request to /flashcard-decks/:id', () async {
      // arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/flashcard-decks/1'),
        ),
      );

      // act
      await datasource.deleteDeck(1);

      // assert
      verify(() => mockDio.delete('/flashcard-decks/1')).called(1);
    });
  });
}
