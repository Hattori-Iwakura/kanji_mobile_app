import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/flashcard/domain/entities/flashcard_card_entity.dart';
import 'package:kanji_flutter/features/flashcard/domain/entities/flashcard_deck_entity.dart';
import 'package:kanji_flutter/features/flashcard/domain/entities/flashcard_exception.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/add_card_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/approve_publish_request_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/create_deck_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/delete_deck_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/get_all_decks_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/get_deck_by_id_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/get_publish_requests_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/reject_publish_request_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/remove_card_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/request_publish_usecase.dart';
import 'package:kanji_flutter/features/flashcard/domain/usecases/update_deck_usecase.dart';
import 'package:kanji_flutter/features/flashcard/presentation/bloc/flashcard_bloc.dart';
import 'package:kanji_flutter/features/flashcard/presentation/bloc/flashcard_event.dart';
import 'package:kanji_flutter/features/flashcard/presentation/bloc/flashcard_state.dart';

import 'flashcard_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllDecksUseCase,
  GetDeckByIdUseCase,
  CreateDeckUseCase,
  UpdateDeckUseCase,
  DeleteDeckUseCase,
  AddCardUseCase,
  RemoveCardUseCase,
  RequestPublishUseCase,
  GetPublishRequestsUseCase,
  ApprovePublishRequestUseCase,
  RejectPublishRequestUseCase,
])
void main() {
  late FlashcardBloc flashcardBloc;
  late MockGetAllDecksUseCase mockGetAllDecksUseCase;
  late MockGetDeckByIdUseCase mockGetDeckByIdUseCase;
  late MockCreateDeckUseCase mockCreateDeckUseCase;
  late MockUpdateDeckUseCase mockUpdateDeckUseCase;
  late MockDeleteDeckUseCase mockDeleteDeckUseCase;
  late MockAddCardUseCase mockAddCardUseCase;
  late MockRemoveCardUseCase mockRemoveCardUseCase;
  late MockRequestPublishUseCase mockRequestPublishUseCase;
  late MockGetPublishRequestsUseCase mockGetPublishRequestsUseCase;
  late MockApprovePublishRequestUseCase mockApprovePublishRequestUseCase;
  late MockRejectPublishRequestUseCase mockRejectPublishRequestUseCase;

  setUp(() {
    mockGetAllDecksUseCase = MockGetAllDecksUseCase();
    mockGetDeckByIdUseCase = MockGetDeckByIdUseCase();
    mockCreateDeckUseCase = MockCreateDeckUseCase();
    mockUpdateDeckUseCase = MockUpdateDeckUseCase();
    mockDeleteDeckUseCase = MockDeleteDeckUseCase();
    mockAddCardUseCase = MockAddCardUseCase();
    mockRemoveCardUseCase = MockRemoveCardUseCase();
    mockRequestPublishUseCase = MockRequestPublishUseCase();
    mockGetPublishRequestsUseCase = MockGetPublishRequestsUseCase();
    mockApprovePublishRequestUseCase = MockApprovePublishRequestUseCase();
    mockRejectPublishRequestUseCase = MockRejectPublishRequestUseCase();

    flashcardBloc = FlashcardBloc(
      getAllDecksUseCase: mockGetAllDecksUseCase,
      getDeckByIdUseCase: mockGetDeckByIdUseCase,
      createDeckUseCase: mockCreateDeckUseCase,
      updateDeckUseCase: mockUpdateDeckUseCase,
      deleteDeckUseCase: mockDeleteDeckUseCase,
      addCardUseCase: mockAddCardUseCase,
      removeCardUseCase: mockRemoveCardUseCase,
      requestPublishUseCase: mockRequestPublishUseCase,
      getPublishRequestsUseCase: mockGetPublishRequestsUseCase,
      approvePublishRequestUseCase: mockApprovePublishRequestUseCase,
      rejectPublishRequestUseCase: mockRejectPublishRequestUseCase,
    );
  });

  tearDown(() {
    flashcardBloc.close();
  });

  final tDeck = FlashcardDeckEntity(
    id: 1,
    name: 'N5 Deck',
    description: 'JLPT N5 flashcards',
    userId: 1,
    sourceType: 'custom',
    sourceId: null,
    isPublic: true,
    totalCards: 10,
    cardsDue: 5,
    cardsNew: 3,
    createAt: DateTime(2024, 1, 1),
    updateAt: DateTime(2024, 1, 1),
  );

  final tDecks = [tDeck];

  final tCard = FlashcardCardEntity(
    id: 1,
    deckId: 1,
    kanjiId: 1,
    frontContent: '日',
    backContent: const {'meaning': 'sun', 'reading': 'にち'},
    difficulty: 0,
    orderIndex: 1,
    nextReviewAt: DateTime(2024, 1, 2),
    intervalDays: 1,
    easeFactor: 2.5,
    repetitions: 0,
    lastReviewedAt: null,
    isNew: true,
    createAt: DateTime(2024, 1, 1),
    updateAt: DateTime(2024, 1, 1),
  );

  group('FlashcardBloc', () {
    test('initial state is FlashcardInitial', () {
      expect(flashcardBloc.state, FlashcardInitial());
    });

    group('LoadAllDecksEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DecksLoaded] when loading succeeds',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tDecks);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadAllDecksEvent()),
        expect: () => [
          FlashcardLoading(),
          isA<DecksLoaded>().having((s) => s.decks, 'decks', tDecks),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DecksLoaded] with search filter',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tDecks);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadAllDecksEvent(search: 'N5')),
        expect: () => [
          FlashcardLoading(),
          isA<DecksLoaded>().having(
            (s) => s.appliedSearch,
            'appliedSearch',
            'N5',
          ),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DecksLoaded] with pagination',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tDecks);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadAllDecksEvent(limit: 20, offset: 20)),
        expect: () => [
          FlashcardLoading(),
          isA<DecksLoaded>()
              .having((s) => s.appliedLimit, 'appliedLimit', 20)
              .having((s) => s.appliedOffset, 'appliedOffset', 20),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when loading fails',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenThrow(FlashcardException('Network error'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadAllDecksEvent()),
        expect: () => [FlashcardLoading(), FlashcardError('Network error')],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] with generic error',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenThrow(Exception('Unknown error'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadAllDecksEvent()),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Failed to load decks'),
        ],
      );
    });

    group('LoadDeckByIdEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DeckDetailLoaded] when loading by ID succeeds',
        build: () {
          when(mockGetDeckByIdUseCase.call(any)).thenAnswer((_) async => tDeck);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadDeckByIdEvent(1)),
        expect: () => [FlashcardLoading(), DeckDetailLoaded(tDeck)],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when deck not found',
        build: () {
          when(
            mockGetDeckByIdUseCase.call(any),
          ).thenThrow(FlashcardException('Deck not found'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadDeckByIdEvent(999)),
        expect: () => [FlashcardLoading(), FlashcardError('Deck not found')],
      );
    });

    group('CreateDeckEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DeckCreated] when creation succeeds',
        build: () {
          when(
            mockCreateDeckUseCase.call(
              name: anyNamed('name'),
              description: anyNamed('description'),
              kanjiIds: anyNamed('kanjiIds'),
            ),
          ).thenAnswer((_) async => tDeck);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(
          CreateDeckEvent(
            name: 'My Deck',
            description: 'Test deck',
            kanjiIds: const [1, 2],
          ),
        ),
        expect: () => [FlashcardLoading(), DeckCreated(tDeck)],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when creation fails',
        build: () {
          when(
            mockCreateDeckUseCase.call(
              name: anyNamed('name'),
              description: anyNamed('description'),
              kanjiIds: anyNamed('kanjiIds'),
            ),
          ).thenThrow(FlashcardException('Failed to create deck'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(CreateDeckEvent(name: 'My Deck')),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Failed to create deck'),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when name is empty',
        build: () {
          when(
            mockCreateDeckUseCase.call(
              name: anyNamed('name'),
              description: anyNamed('description'),
              kanjiIds: anyNamed('kanjiIds'),
            ),
          ).thenThrow(FlashcardException('Deck name is required'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(CreateDeckEvent(name: '')),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Deck name is required'),
        ],
      );
    });

    group('UpdateDeckEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DeckUpdated] when update succeeds',
        build: () {
          when(
            mockUpdateDeckUseCase.call(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenAnswer((_) async => tDeck);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(
          UpdateDeckEvent(
            id: 1,
            name: 'Updated Deck',
            description: 'Updated description',
            isPublic: true,
          ),
        ),
        expect: () => [FlashcardLoading(), DeckUpdated(tDeck)],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when update fails - unauthorized',
        build: () {
          when(
            mockUpdateDeckUseCase.call(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenThrow(FlashcardException('Unauthorized'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(UpdateDeckEvent(id: 1, name: 'Updated')),
        expect: () => [FlashcardLoading(), FlashcardError('Unauthorized')],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when deck not found',
        build: () {
          when(
            mockUpdateDeckUseCase.call(
              id: anyNamed('id'),
              name: anyNamed('name'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenThrow(FlashcardException('Deck not found'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(UpdateDeckEvent(id: 999, name: 'Updated')),
        expect: () => [FlashcardLoading(), FlashcardError('Deck not found')],
      );
    });

    group('DeleteDeckEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DeckDeleted] when deletion succeeds',
        build: () {
          when(mockDeleteDeckUseCase.call(any)).thenAnswer((_) async => {});
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(DeleteDeckEvent(1)),
        expect: () => [FlashcardLoading(), DeckDeleted()],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when deletion fails - not found',
        build: () {
          when(
            mockDeleteDeckUseCase.call(any),
          ).thenThrow(FlashcardException('Deck not found'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(DeleteDeckEvent(999)),
        expect: () => [FlashcardLoading(), FlashcardError('Deck not found')],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when deletion fails - unauthorized',
        build: () {
          when(
            mockDeleteDeckUseCase.call(any),
          ).thenThrow(FlashcardException('Cannot delete system deck'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(DeleteDeckEvent(1)),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Cannot delete system deck'),
        ],
      );
    });

    group('AddCardEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, CardAdded] when adding card succeeds',
        build: () {
          when(
            mockAddCardUseCase.call(
              deckId: anyNamed('deckId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => tCard);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(AddCardEvent(deckId: 1, kanjiId: 10)),
        expect: () => [FlashcardLoading(), CardAdded(tCard)],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when card already exists',
        build: () {
          when(
            mockAddCardUseCase.call(
              deckId: anyNamed('deckId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(FlashcardException('Card already exists in deck'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(AddCardEvent(deckId: 1, kanjiId: 10)),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Card already exists in deck'),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when kanji not found',
        build: () {
          when(
            mockAddCardUseCase.call(
              deckId: anyNamed('deckId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(FlashcardException('Kanji not found'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(AddCardEvent(deckId: 1, kanjiId: 999)),
        expect: () => [FlashcardLoading(), FlashcardError('Kanji not found')],
      );
    });

    group('RemoveCardEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, CardRemoved] when removal succeeds',
        build: () {
          when(
            mockRemoveCardUseCase.call(
              deckId: anyNamed('deckId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => {});
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RemoveCardEvent(deckId: 1, kanjiId: 10)),
        expect: () => [FlashcardLoading(), CardRemoved()],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when card not in deck',
        build: () {
          when(
            mockRemoveCardUseCase.call(
              deckId: anyNamed('deckId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenThrow(FlashcardException('Card not in deck'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RemoveCardEvent(deckId: 1, kanjiId: 10)),
        expect: () => [FlashcardLoading(), FlashcardError('Card not in deck')],
      );
    });

    group('RequestPublishEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, PublishRequested] when request succeeds',
        build: () {
          when(mockRequestPublishUseCase.call(any)).thenAnswer((_) async => {});
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RequestPublishEvent(1)),
        expect: () => [FlashcardLoading(), PublishRequested()],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when deck already published',
        build: () {
          when(
            mockRequestPublishUseCase.call(any),
          ).thenThrow(FlashcardException('Deck already published'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RequestPublishEvent(1)),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Deck already published'),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when deck has no cards',
        build: () {
          when(
            mockRequestPublishUseCase.call(any),
          ).thenThrow(FlashcardException('Deck must have at least one card'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RequestPublishEvent(1)),
        expect: () => [
          FlashcardLoading(),
          FlashcardError('Deck must have at least one card'),
        ],
      );
    });

    group('LoadPublishRequestsEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, PublishRequestsLoaded] when loading succeeds',
        build: () {
          when(
            mockGetPublishRequestsUseCase.call(status: anyNamed('status')),
          ).thenAnswer((_) async => []);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadPublishRequestsEvent()),
        expect: () => [FlashcardLoading(), PublishRequestsLoaded([])],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, PublishRequestsLoaded] with status filter',
        build: () {
          when(
            mockGetPublishRequestsUseCase.call(status: anyNamed('status')),
          ).thenAnswer((_) async => []);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(LoadPublishRequestsEvent(status: 'pending')),
        expect: () => [FlashcardLoading(), PublishRequestsLoaded([])],
      );
    });

    group('ApprovePublishRequestEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, PublishRequestApproved] when approval succeeds',
        build: () {
          when(
            mockApprovePublishRequestUseCase.call(any),
          ).thenAnswer((_) async => {});
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(ApprovePublishRequestEvent(1)),
        expect: () => [FlashcardLoading(), PublishRequestApproved()],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when request not found',
        build: () {
          when(
            mockApprovePublishRequestUseCase.call(any),
          ).thenThrow(FlashcardException('Request not found'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(ApprovePublishRequestEvent(999)),
        expect: () => [FlashcardLoading(), FlashcardError('Request not found')],
      );
    });

    group('RejectPublishRequestEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, PublishRequestRejected] when rejection succeeds',
        build: () {
          when(
            mockRejectPublishRequestUseCase.call(any, any),
          ).thenAnswer((_) async => {});
          return flashcardBloc;
        },
        act: (bloc) =>
            bloc.add(RejectPublishRequestEvent(1, reason: 'Quality issues')),
        expect: () => [FlashcardLoading(), PublishRequestRejected()],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, FlashcardError] when request not found',
        build: () {
          when(
            mockRejectPublishRequestUseCase.call(any, any),
          ).thenThrow(FlashcardException('Request not found'));
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RejectPublishRequestEvent(999)),
        expect: () => [FlashcardLoading(), FlashcardError('Request not found')],
      );
    });

    group('RefreshDecksEvent', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'emits [FlashcardLoading, DecksLoaded] when refresh succeeds',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tDecks);
          return flashcardBloc;
        },
        act: (bloc) => bloc.add(RefreshDecksEvent()),
        expect: () => [FlashcardLoading(), isA<DecksLoaded>()],
      );
    });

    group('Multiple Events Sequence', () {
      blocTest<FlashcardBloc, FlashcardState>(
        'handles load decks followed by load detail correctly',
        build: () {
          when(
            mockGetAllDecksUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tDecks);
          when(mockGetDeckByIdUseCase.call(any)).thenAnswer((_) async => tDeck);
          return flashcardBloc;
        },
        act: (bloc) {
          bloc.add(LoadAllDecksEvent());
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(LoadDeckByIdEvent(1));
          });
        },
        expect: () => [
          FlashcardLoading(),
          isA<DecksLoaded>(),
          FlashcardLoading(),
          DeckDetailLoaded(tDeck),
        ],
      );

      blocTest<FlashcardBloc, FlashcardState>(
        'handles create deck followed by add card',
        build: () {
          when(
            mockCreateDeckUseCase.call(
              name: anyNamed('name'),
              description: anyNamed('description'),
              kanjiIds: anyNamed('kanjiIds'),
            ),
          ).thenAnswer((_) async => tDeck);
          when(
            mockAddCardUseCase.call(
              deckId: anyNamed('deckId'),
              kanjiId: anyNamed('kanjiId'),
            ),
          ).thenAnswer((_) async => tCard);
          return flashcardBloc;
        },
        act: (bloc) {
          bloc.add(CreateDeckEvent(name: 'New Deck'));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(AddCardEvent(deckId: 1, kanjiId: 10));
          });
        },
        expect: () => [
          FlashcardLoading(),
          DeckCreated(tDeck),
          FlashcardLoading(),
          CardAdded(tCard),
        ],
      );
    });
  });
}
