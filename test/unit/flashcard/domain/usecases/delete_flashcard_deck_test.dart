import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_deck_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/delete_flashcard_deck.dart';
import 'package:mocktail/mocktail.dart';

class MockFlashcardDeckRepository extends Mock
    implements FlashcardDeckRepository {}

void main() {
  late DeleteFlashcardDeck usecase;
  late MockFlashcardDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardDeckRepository();
    usecase = DeleteFlashcardDeck(mockRepository);
  });

  const tId = 1;

  group('DeleteFlashcardDeck', () {
    test('should delete deck by id', () async {
      // arrange
      when(
        () => mockRepository.deleteDeck(any()),
      ).thenAnswer((_) async => const Right<Failure, void>(null));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRepository.deleteDeck(tId)).called(1);
    });

    test('should return failure when deck not found', () async {
      // arrange
      when(
        () => mockRepository.deleteDeck(any()),
      ).thenAnswer((_) async => const Left(NotFoundFailure('Deck not found')));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(NotFoundFailure('Deck not found')));
      verify(() => mockRepository.deleteDeck(tId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.deleteDeck(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(ServerFailure('Delete failed')));
      verify(() => mockRepository.deleteDeck(tId)).called(1);
    });
  });
}
