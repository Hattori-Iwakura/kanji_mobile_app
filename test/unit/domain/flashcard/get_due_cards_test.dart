import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/get_due_cards.dart';

class MockFlashcardRepository extends Mock implements FlashcardRepository {}

void main() {
  late GetDueCards usecase;
  late MockFlashcardRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardRepository();
    usecase = GetDueCards(mockRepository);
  });

  const testDeckId = 'deck1';

  final testCard1 = Flashcard(
    id: 'card1',
    deckId: testDeckId,
    kanjiId: '1',
    front: '日',
    back: 'sun, day',
    hint: 'ニチ、ジツ / ひ、か',
    interval: 1,
    repetitions: 1,
    nextReviewAt: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  final testCard2 = Flashcard(
    id: 'card2',
    deckId: testDeckId,
    kanjiId: '2',
    front: '月',
    back: 'moon, month',
    hint: 'ゲツ、ガツ / つき',
    interval: 1,
    repetitions: 1,
    nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  final testDueCards = [testCard1, testCard2];

  group('GetDueCards', () {
    test('should return list of due cards when successful', () async {
      // arrange
      when(
        () => mockRepository.getDueCards(testDeckId),
      ).thenAnswer((_) async => Right(testDueCards));

      // act
      final result = await usecase(testDeckId);

      // assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (cards) {
        expect(cards, equals(testDueCards));
        expect(cards.length, equals(2));
      });
      verify(() => mockRepository.getDueCards(testDeckId)).called(1);
    });

    test('should return empty list when no cards are due', () async {
      // arrange
      when(
        () => mockRepository.getDueCards(testDeckId),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(testDeckId);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (cards) => expect(cards, isEmpty),
      );
    });

    test('should return cards with correct properties', () async {
      // arrange
      when(
        () => mockRepository.getDueCards(testDeckId),
      ).thenAnswer((_) async => Right(testDueCards));

      // act
      final result = await usecase(testDeckId);

      // assert
      result.fold((failure) => fail('Expected Right but got Left'), (cards) {
        final card1 = cards[0];
        expect(card1.id, equals('card1'));
        expect(card1.front, equals('日'));
        expect(card1.back, equals('sun, day'));
        expect(card1.isDue, true);

        final card2 = cards[1];
        expect(card2.id, equals('card2'));
        expect(card2.front, equals('月'));
        expect(card2.back, equals('moon, month'));
        expect(card2.isDue, true);
      });
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      final failure = ServerFailure('Failed to fetch due cards');
      when(
        () => mockRepository.getDueCards(testDeckId),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testDeckId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, equals(failure)),
        (cards) => fail('Expected Left but got Right'),
      );
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // arrange
      final failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.getDueCards(testDeckId),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(testDeckId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error, equals(failure)),
        (cards) => fail('Expected Left but got Right'),
      );
    });

    test('should handle different deck IDs', () async {
      // arrange
      const deck2Id = 'deck2';
      when(
        () => mockRepository.getDueCards(deck2Id),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await usecase(deck2Id);

      // assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getDueCards(deck2Id)).called(1);
    });
  });
}
