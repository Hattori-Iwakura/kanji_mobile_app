import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_deck_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/create_flashcard_deck.dart';
import 'package:mocktail/mocktail.dart';

class MockFlashcardDeckRepository extends Mock
    implements FlashcardDeckRepository {}

void main() {
  late CreateFlashcardDeck usecase;
  late MockFlashcardDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardDeckRepository();
    usecase = CreateFlashcardDeck(mockRepository);
  });

  final tDeck = FlashcardDeckNew(
    id: 1,
    name: 'My Deck',
    description: 'Test deck',
    userId: 1,
    isPublic: false,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    cards: const [],
    userName: 'Test User',
  );

  const tName = 'My Deck';
  const tDescription = 'Test deck';
  const tKanjiIds = [1, 2, 3];

  group('CreateFlashcardDeck', () {
    test('should create deck with name only', () async {
      // arrange
      when(
        () => mockRepository.createDeck(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Right<Failure, FlashcardDeckNew>(tDeck));

      // act
      final result = await usecase(name: tName);

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (deck) => expect(deck.name, tName),
      );
      verify(
        () => mockRepository.createDeck(
          name: tName,
          description: null,
          kanjiIds: null,
        ),
      ).called(1);
    });

    test('should create deck with name and description', () async {
      // arrange
      when(
        () => mockRepository.createDeck(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Right<Failure, FlashcardDeckNew>(tDeck));

      // act
      final result = await usecase(name: tName, description: tDescription);

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      verify(
        () => mockRepository.createDeck(
          name: tName,
          description: tDescription,
          kanjiIds: null,
        ),
      ).called(1);
    });

    test('should create deck with kanji IDs', () async {
      // arrange
      when(
        () => mockRepository.createDeck(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer((_) async => Right<Failure, FlashcardDeckNew>(tDeck));

      // act
      final result = await usecase(
        name: tName,
        description: tDescription,
        kanjiIds: tKanjiIds,
      );

      // assert
      expect(result, isA<Right<Failure, FlashcardDeckNew>>());
      verify(
        () => mockRepository.createDeck(
          name: tName,
          description: tDescription,
          kanjiIds: tKanjiIds,
        ),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.createDeck(
          name: any(named: 'name'),
          description: any(named: 'description'),
          kanjiIds: any(named: 'kanjiIds'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Failed to create deck')),
      );

      // act
      final result = await usecase(name: tName);

      // assert
      expect(result, const Left(ServerFailure('Failed to create deck')));
      verify(
        () => mockRepository.createDeck(
          name: tName,
          description: null,
          kanjiIds: null,
        ),
      ).called(1);
    });
  });
}
