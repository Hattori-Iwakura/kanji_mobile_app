import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck_new.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_deck_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/get_all_flashcard_decks.dart';
import 'package:mocktail/mocktail.dart';

class MockFlashcardDeckRepository extends Mock
    implements FlashcardDeckRepository {}

void main() {
  late GetAllFlashcardDecks usecase;
  late MockFlashcardDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockFlashcardDeckRepository();
    usecase = GetAllFlashcardDecks(mockRepository);
  });

  final tDeck1 = FlashcardDeckNew(
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

  final tDeck2 = FlashcardDeckNew(
    id: 2,
    name: 'JLPT N4',
    description: 'N4 kanji',
    userId: 1,
    isPublic: true,
    createdAt: DateTime(2024, 2, 1),
    updatedAt: DateTime(2024, 2, 15),
    cards: const [],
    userName: 'Test User',
  );

  final List<FlashcardDeckNew> tDeckList = [tDeck1, tDeck2];

  group('GetAllFlashcardDecks', () {
    test('should get all decks from repository', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(tDeckList));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tDeckList));
      verify(
        () =>
            mockRepository.getAllDecks(search: null, limit: null, offset: null),
      ).called(1);
    });

    test('should get decks with search parameter', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<FlashcardDeckNew>>([tDeck1]),
      );

      // act
      final result = await usecase(search: 'N5');

      // assert
      expect(result, isA<Right<Failure, List<FlashcardDeckNew>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (decks) => expect(decks, [tDeck1]),
      );
      verify(
        () =>
            mockRepository.getAllDecks(search: 'N5', limit: null, offset: null),
      ).called(1);
    });

    test('should get decks with limit and offset', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer(
        (_) async => Right<Failure, List<FlashcardDeckNew>>([tDeck1]),
      );

      // act
      final result = await usecase(limit: 10, offset: 0);

      // assert
      expect(result, isA<Right<Failure, List<FlashcardDeckNew>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (decks) => expect(decks, [tDeck1]),
      );
      verify(
        () => mockRepository.getAllDecks(search: null, limit: 10, offset: 0),
      ).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('Server error')));

      // act
      final result = await usecase();

      // assert
      expect(result, const Left(ServerFailure('Server error')));
      verify(
        () =>
            mockRepository.getAllDecks(search: null, limit: null, offset: null),
      ).called(1);
    });

    test('should return empty list when no decks found', () async {
      // arrange
      when(
        () => mockRepository.getAllDecks(
          search: any(named: 'search'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer(
        (_) async => const Right<Failure, List<FlashcardDeckNew>>([]),
      );

      // act
      final result = await usecase();

      // assert
      expect(result, isA<Right<Failure, List<FlashcardDeckNew>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (decks) => expect(decks, isEmpty),
      );
      verify(
        () =>
            mockRepository.getAllDecks(search: null, limit: null, offset: null),
      ).called(1);
    });
  });
}
