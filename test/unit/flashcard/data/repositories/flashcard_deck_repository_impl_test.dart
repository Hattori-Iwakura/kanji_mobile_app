import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/auth/data/models/user_model.dart';
import 'package:kanji_mobile_v1/features/flashcard/data/datasources/flashcard_deck_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/flashcard/data/models/flashcard_deck_new_model.dart';
import 'package:kanji_mobile_v1/features/flashcard/data/repositories/flashcard_deck_repository_impl.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';
import 'package:mocktail/mocktail.dart';

class MockFlashcardDeckRemoteDataSource extends Mock
    implements FlashcardDeckRemoteDataSource {}

void main() {
  late FlashcardDeckRepositoryImpl repository;
  late MockFlashcardDeckRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockFlashcardDeckRemoteDataSource();
    repository = FlashcardDeckRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tDeckModel = FlashcardDeckNewModel(
    id: 1,
    name: 'Test Deck',
    description: 'Description',
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

  final tDecksResponse = FlashcardDecksResponse(
    data: [tDeckModel],
    total: 1,
    limit: 10,
    offset: 0,
  );

  group('getAllDecks', () {
    test('should return list of FlashcardDeckNew when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => tDecksResponse);

      // act
      final result = await repository.getAllDecks();

      // assert
      expect(result, isA<Right<Failure, List<FlashcardDeckNew>>>());
      result.fold((failure) => fail('Expected Right but got Left'), (decks) {
        expect(decks, isA<List<FlashcardDeckNew>>());
        expect(decks.length, 1);
        expect(decks.first.name, 'Test Deck');
      });
      verify(
        () => mockRemoteDataSource.getAllDecks(
          search: null,
          limit: null,
          offset: null,
        ),
      ).called(1);
    });

    test('should return ServerFailure when exception occurs', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(Exception('Server error'));

      // act
      final result = await repository.getAllDecks();

      // assert
      expect(result, isA<Left<Failure, List<FlashcardDeckNew>>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (decks) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getDeckById', () {
    test('should return FlashcardDeckNew when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getDeckById(any()),
      ).thenAnswer((_) async => tDeckModel);

      // act
      final result = await repository.getDeckById(1);

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      result.fold((failure) => fail('Expected Right but got Left'), (deck) {
        expect(deck, isA<FlashcardDeckNew>());
        expect(deck.id, 1);
        expect(deck.name, 'Test Deck');
      });
      verify(() => mockRemoteDataSource.getDeckById(1)).called(1);
    });

    test(
      'should return NotFoundFailure when DioException 404 occurs',
      () async {
        // arrange
        when(() => mockRemoteDataSource.getDeckById(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/flashcard-decks/999'),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: '/flashcard-decks/999'),
            ),
          ),
        );

        // act
        final result = await repository.getDeckById(999);

        // assert
        expect(result, isA<Left<Failure, FlashcardDeckNew>>());
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (deck) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('createDeck', () {
    test('should return FlashcardDeckNew when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.createDeck(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => tDeckModel);

      // act
      final result = await repository.createDeck(name: 'Test Deck');

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (deck) => expect(deck.name, 'Test Deck'),
      );
      verify(
        () => mockRemoteDataSource.createDeck(
          name: 'Test Deck',
          description: null,
          kanjiIds: null,
        ),
      ).called(1);
    });

    test('should return Failure when exception occurs', () async {
      // arrange
      when(
        () => mockRemoteDataSource.createDeck(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenThrow(Exception('Create failed'));

      // act
      final result = await repository.createDeck(name: 'Test Deck');

      // assert
      expect(result, isA<Left<Failure, FlashcardDeckNew>>());
    });
  });

  group('updateDeck', () {
    test('should return updated FlashcardDeckNew when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.updateDeck(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => tDeckModel);

      // act
      final result = await repository.updateDeck(id: 1, name: 'Updated Deck');

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      verify(
        () => mockRemoteDataSource.updateDeck(
          id: 1,
          name: 'Updated Deck',
          description: null,
          isPublic: null,
        ),
      ).called(1);
    });

    test('should return Failure when exception occurs', () async {
      // arrange
      when(
        () => mockRemoteDataSource.updateDeck(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenThrow(Exception('Update failed'));

      // act
      final result = await repository.updateDeck(id: 1, name: 'Updated Deck');

      // assert
      expect(result, isA<Left<Failure, FlashcardDeckNew>>());
    });
  });

  group('deleteDeck', () {
    test('should return Right(void) when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.deleteDeck(any()),
      ).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.deleteDeck(1);

      // assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRemoteDataSource.deleteDeck(1)).called(1);
    });

    test('should return Failure when exception occurs', () async {
      // arrange
      when(
        () => mockRemoteDataSource.deleteDeck(any()),
      ).thenThrow(Exception('Delete failed'));

      // act
      final result = await repository.deleteDeck(1);

      // assert
      expect(result, isA<Left<Failure, void>>());
    });
  });
}
