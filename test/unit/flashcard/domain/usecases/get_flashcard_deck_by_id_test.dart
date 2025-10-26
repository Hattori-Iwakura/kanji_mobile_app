import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_deck_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/get_flashcard_deck_by_id.dart';
import 'package:mocktail/mocktail.dart';

class MockFlashcardDeckRepository extends Mock
    implements FlashcardDeckRepository {}

void main() {
  late GetFlashcardDeckById usecase;
  late MockFlashcardDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardDeckRepository();
    usecase = GetFlashcardDeckById(mockRepository);
  });

  final tDeck = FlashcardDeckNew(
    id: 1,
    name: 'JLPT N5',
    description: 'N5 kanji',
    userId: 1,
    isPublic: false,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 15),
    cards: const [],
    userName: 'Test User',
  );

  const tId = 1;

  group('GetFlashcardDeckById', () {
    test('should get deck by id from repository', () async {
      // arrange
      when(
        () => mockRepository.getDeckById(any()),
      ).thenAnswer((_) async => Right<Failure, FlashcardDeckNew>(tDeck));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      result.fold((failure) => fail('Expected Right but got Left'), (deck) {
        expect(deck.id, tId);
        expect(deck.name, 'JLPT N5');
      });
      verify(() => mockRepository.getDeckById(tId)).called(1);
    });

    test('should return failure when deck not found', () async {
      // arrange
      when(
        () => mockRepository.getDeckById(any()),
      ).thenAnswer((_) async => const Left(NotFoundFailure('Deck not found')));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(NotFoundFailure('Deck not found')));
      verify(() => mockRepository.getDeckById(tId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.getDeckById(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Left(ServerFailure('Server error')));
      verify(() => mockRepository.getDeckById(tId)).called(1);
    });
  });
}
