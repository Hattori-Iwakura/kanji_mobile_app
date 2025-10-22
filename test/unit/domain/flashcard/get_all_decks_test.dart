import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/get_all_decks.dart';

class MockFlashcardRepository extends Mock implements FlashcardRepository {}

void main() {
  late GetAllDecks usecase;
  late MockFlashcardRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardRepository();
    usecase = GetAllDecks(mockRepository);
  });

  final testDeck1 = FlashcardDeck(
    id: '1',
    userId: 'user1',
    name: 'JLPT N5 Vocabulary',
    description: 'Basic Japanese vocabulary',
    totalCards: 100,
    dueCards: 10,
    newCards: 20,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testDeck2 = FlashcardDeck(
    id: '2',
    userId: 'user1',
    name: 'Hiragana Practice',
    description: 'Learn all hiragana characters',
    totalCards: 46,
    dueCards: 5,
    newCards: 15,
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  final testDecks = [testDeck1, testDeck2];

  group('GetAllDecks', () {
    test('should return list of decks when successful', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(),
      ).thenAnswer((_) async => Right(testDecks));

      // act
      final result = await usecase();

      // assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (decks) {
        expect(decks, equals(testDecks));
        expect(decks.length, equals(2));
      });
      verify(() => mockRepository.getAllDecks()).called(1);
    });

    test('should return empty list when no decks exist', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase();

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (decks) => expect(decks, isEmpty),
      );
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      final failure = ServerFailure('Failed to fetch decks');
      when(
        () => mockRepository.getAllDecks(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, equals(failure)),
        (decks) => fail('Expected Left but got Right'),
      );
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.getAllDecks(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, equals(failure)),
        (decks) => fail('Expected Left but got Right'),
      );
    });

    test('should return decks with correct properties', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(),
      ).thenAnswer((_) async => Right(testDecks));

      // act
      final result = await usecase();

      // assert
      result.fold((failure) => fail('Expected Right but got Left'), (decks) {
        final deck1 = decks[0];
        expect(deck1.id, equals('1'));
        expect(deck1.name, equals('JLPT N5 Vocabulary'));
        expect(deck1.totalCards, equals(100));
        expect(deck1.dueCards, equals(10));
        expect(deck1.newCards, equals(20));

        final deck2 = decks[1];
        expect(deck2.id, equals('2'));
        expect(deck2.name, equals('Hiragana Practice'));
        expect(deck2.totalCards, equals(46));
      });
    });
  });
}
