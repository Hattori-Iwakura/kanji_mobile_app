import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_deck_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/update_flashcard_deck.dart';
import 'package:mocktail/mocktail.dart';

class MockFlashcardDeckRepository extends Mock
    implements FlashcardDeckRepository {}

void main() {
  late UpdateFlashcardDeck usecase;
  late MockFlashcardDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardDeckRepository();
    usecase = UpdateFlashcardDeck(mockRepository);
  });

  final tUpdatedDeck = FlashcardDeckNew(
    id: 1,
    name: 'Updated Deck',
    description: 'Updated description',
    userId: 1,
    isPublic: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 20),
    cards: const [],
    userName: 'Test User',
  );

  const tId = 1;
  const tName = 'Updated Deck';
  const tDescription = 'Updated description';
  const tIsPublic = true;

  group('UpdateFlashcardDeck', () {
    test('should update deck with name', () async {
      // arrange
      when(
        () => mockRepository.updateDeck(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => Right<Failure, FlashcardDeckNew>(tUpdatedDeck));

      // act
      final result = await usecase(id: tId, name: tName);

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      verify(
        () => mockRepository.updateDeck(
          id: tId,
          name: tName,
          description: null,
          isPublic: null,
        ),
      ).called(1);
    });

    test('should update deck with all fields', () async {
      // arrange
      when(
        () => mockRepository.updateDeck(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => Right<Failure, FlashcardDeckNew>(tUpdatedDeck));

      // act
      final result = await usecase(
        id: tId,
        name: tName,
        description: tDescription,
        isPublic: tIsPublic,
      );

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      verify(
        () => mockRepository.updateDeck(
          id: tId,
          name: tName,
          description: tDescription,
          isPublic: tIsPublic,
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.updateDeck(
          id: any(named: 'id'),
          name: any(named: 'name'),
          description: any(named: 'description'),
          isPublic: any(named: 'isPublic'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));

      // act
      final result = await usecase(id: tId, name: tName);

      // assert
      expect(result, const Left(ServerFailure('Update failed')));
      verify(
        () => mockRepository.updateDeck(
          id: tId,
          name: tName,
          description: null,
          isPublic: null,
        ),
      ).called(1);
    });
  });
}
