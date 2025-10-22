import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kanji_mobile_v1/core/error/failures.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/flashcard_deck.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/entities/study_progress.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/repositories/flashcard_repository.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/get_all_decks.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/get_due_cards.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/save_study_progress.dart';
import 'package:kanji_mobile_v1/features/flashcard/domain/usecases/update_card_review.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_bloc.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_event.dart';
import 'package:kanji_mobile_v1/features/flashcard/presentation/bloc/flashcard_state.dart';

class MockGetAllDecks extends Mock implements GetAllDecks {}

class MockGetDueCards extends Mock implements GetDueCards {}

class MockUpdateCardReview extends Mock implements UpdateCardReview {}

class MockSaveStudyProgress extends Mock implements SaveStudyProgress {}

class MockFlashcardRepository extends Mock implements FlashcardRepository {}

void main() {
  late FlashcardBloc bloc;
  late MockGetAllDecks mockGetAllDecks;
  late MockGetDueCards mockGetDueCards;
  late MockUpdateCardReview mockUpdateCardReview;
  late MockSaveStudyProgress mockSaveStudyProgress;
  late MockFlashcardRepository mockRepository;

  setUp(() {
    mockGetAllDecks = MockGetAllDecks();
    mockGetDueCards = MockGetDueCards();
    mockUpdateCardReview = MockUpdateCardReview();
    mockSaveStudyProgress = MockSaveStudyProgress();
    mockRepository = MockFlashcardRepository();

    bloc = FlashcardBloc(
      getAllDecks: mockGetAllDecks,
      getDueCards: mockGetDueCards,
      updateCardReview: mockUpdateCardReview,
      saveStudyProgress: mockSaveStudyProgress,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testDeck = FlashcardDeck(
    id: '1',
    userId: 'user1',
    name: 'JLPT N5',
    description: 'Basic vocabulary',
    totalCards: 100,
    dueCards: 10,
    newCards: 20,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final testDecks = [testDeck];

  final testCard = Flashcard(
    id: 'card1',
    deckId: '1',
    kanjiId: '1',
    front: '日',
    back: 'sun, day',
    interval: 1,
    repetitions: 1,
    nextReviewAt: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  final testCards = [testCard];

  final testProgress = StudyProgress(
    id: '1',
    userId: 'user1',
    deckId: '1',
    cardsStudied: 5,
    cardsCorrect: 4,
    cardsIncorrect: 1,
    studyDuration: 300,
    sessionDate: DateTime(2024, 1, 1),
    createdAt: DateTime(2024, 1, 1),
  );

  group('FlashcardBloc', () {
    test('initial state is FlashcardInitial', () {
      expect(bloc.state, equals(FlashcardInitial()));
    });

    group('LoadDecksEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DecksLoaded] when getAllDecks succeeds',
        build: () {
          when(
            () => mockGetAllDecks(),
          ).thenAnswer((_) async => Right(testDecks));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDecksEvent()),
        expect: () => [FlashcardLoading(), DecksLoaded(testDecks)],
        verify: (_) {
          verify(() => mockGetAllDecks()).called(1);
        },
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DecksLoaded] with empty list when no decks exist',
        build: () {
          when(
            () => mockGetAllDecks(),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDecksEvent()),
        expect: () => [FlashcardLoading(), const DecksLoaded([])],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when getAllDecks fails',
        build: () {
          when(() => mockGetAllDecks()).thenAnswer(
            (_) async => Left(ServerFailure('Failed to load decks')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(LoadDecksEvent()),
        expect: () => [
          FlashcardLoading(),
          const FlashcardError('Failed to load decks'),
        ],
      );
    });

    group('StartStudySessionEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, StudySessionActive] when cards are available',
        build: () {
          when(
            () => mockGetDueCards(any()),
          ).thenAnswer((_) async => Right(testCards));
          when(
            () => mockRepository.getNewCards(any(), limit: any(named: 'limit')),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartStudySessionEvent('1')),
        expect: () => [
          FlashcardLoading(),
          StudySessionActive(cards: testCards, currentIndex: 0),
        ],
        verify: (_) {
          verify(() => mockGetDueCards('1')).called(1);
          verify(() => mockRepository.getNewCards('1', limit: 10)).called(1);
        },
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when no cards available',
        build: () {
          when(
            () => mockGetDueCards(any()),
          ).thenAnswer((_) async => const Right([]));
          when(
            () => mockRepository.getNewCards(any(), limit: any(named: 'limit')),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartStudySessionEvent('1')),
        expect: () => [
          FlashcardLoading(),
          const FlashcardError(
            'No cards to review. Add some cards to this deck first.',
          ),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when getDueCards fails',
        build: () {
          when(
            () => mockGetDueCards(any()),
          ).thenAnswer((_) async => Left(NetworkFailure('No internet')));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartStudySessionEvent('1')),
        expect: () => [FlashcardLoading(), const FlashcardError('No internet')],
      );
    });

    group('FlipCardEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'toggles showAnswer when in active study session',
        build: () => bloc,
        seed: () => StudySessionActive(cards: testCards, currentIndex: 0),
        act: (bloc) => bloc.add(FlipCardEvent()),
        expect: () => [
          StudySessionActive(
            cards: testCards,
            currentIndex: 0,
            showAnswer: true,
          ),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'does nothing when not in study session',
        build: () => bloc,
        seed: () => FlashcardInitial(),
        act: (bloc) => bloc.add(FlipCardEvent()),
        expect: () => [],
      );
    });

    group('AnswerCardEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'updates state with correct answer and moves to next card',
        build: () {
          when(
            () => mockUpdateCardReview(
              cardId: any(named: 'cardId'),
              quality: any(named: 'quality'),
            ),
          ).thenAnswer((_) async => Right(testCard));
          return bloc;
        },
        seed: () => StudySessionActive(cards: testCards, currentIndex: 0),
        act: (bloc) =>
            bloc.add(const AnswerCardEvent(cardId: 'card1', quality: 4)),
        expect: () => [
          StudySessionActive(
            cards: testCards,
            currentIndex: 1,
            cardsCorrect: 1,
            cardsIncorrect: 0,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUpdateCardReview(cardId: 'card1', quality: 4),
          ).called(1);
        },
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'updates state with incorrect answer when quality < 3',
        build: () {
          when(
            () => mockUpdateCardReview(
              cardId: any(named: 'cardId'),
              quality: any(named: 'quality'),
            ),
          ).thenAnswer((_) async => Right(testCard));
          return bloc;
        },
        seed: () => StudySessionActive(cards: testCards, currentIndex: 0),
        act: (bloc) =>
            bloc.add(const AnswerCardEvent(cardId: 'card1', quality: 2)),
        expect: () => [
          StudySessionActive(
            cards: testCards,
            currentIndex: 1,
            cardsCorrect: 0,
            cardsIncorrect: 1,
          ),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits FlashcardError when updateCardReview fails',
        build: () {
          when(
            () => mockUpdateCardReview(
              cardId: any(named: 'cardId'),
              quality: any(named: 'quality'),
            ),
          ).thenAnswer((_) async => Left(ServerFailure('Update failed')));
          return bloc;
        },
        seed: () => StudySessionActive(cards: testCards, currentIndex: 0),
        act: (bloc) =>
            bloc.add(const AnswerCardEvent(cardId: 'card1', quality: 4)),
        expect: () => [const FlashcardError('Update failed')],
      );
    });

    group('EndStudySessionEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, StudySessionCompleted] when save succeeds',
        build: () {
          when(
            () => mockSaveStudyProgress(
              deckId: any(named: 'deckId'),
              cardsStudied: any(named: 'cardsStudied'),
              cardsCorrect: any(named: 'cardsCorrect'),
              cardsIncorrect: any(named: 'cardsIncorrect'),
              studyDuration: any(named: 'studyDuration'),
            ),
          ).thenAnswer((_) async => Right(testProgress));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const EndStudySessionEvent(
            deckId: '1',
            cardsStudied: 5,
            cardsCorrect: 4,
            cardsIncorrect: 1,
            studyDuration: 300,
          ),
        ),
        expect: () => [FlashcardLoading(), StudySessionCompleted(testProgress)],
        verify: (_) {
          verify(
            () => mockSaveStudyProgress(
              deckId: '1',
              cardsStudied: 5,
              cardsCorrect: 4,
              cardsIncorrect: 1,
              studyDuration: 300,
            ),
          ).called(1);
        },
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when save fails',
        build: () {
          when(
            () => mockSaveStudyProgress(
              deckId: any(named: 'deckId'),
              cardsStudied: any(named: 'cardsStudied'),
              cardsCorrect: any(named: 'cardsCorrect'),
              cardsIncorrect: any(named: 'cardsIncorrect'),
              studyDuration: any(named: 'studyDuration'),
            ),
          ).thenAnswer((_) async => Left(NetworkFailure('Save failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const EndStudySessionEvent(
            deckId: '1',
            cardsStudied: 5,
            cardsCorrect: 4,
            cardsIncorrect: 1,
            studyDuration: 300,
          ),
        ),
        expect: () => [FlashcardLoading(), const FlashcardError('Save failed')],
      );
    });
  });
}
