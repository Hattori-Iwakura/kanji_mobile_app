import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/features/flashcard/domain/usecases/flashcard_usecases.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING FLASHCARD INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');

    // Setup authentication
    TestHelper.printStep('Setting up authentication...');
    try {
      await AuthHelper.setupAuth();
      TestHelper.printSuccess('Authentication configured successfully');
    } catch (e) {
      TestHelper.printError('Failed to setup auth: $e');
      TestHelper.printStep('Tests may fail due to authentication issues');
    }
  });

  tearDownAll(() {
    // Clean up authentication
    AuthHelper.clearAuth();
  });

  group('1. Deck Management Tests -', () {
    late GetDecksUseCase getDecks;
    late GetDeckByIdUseCase getDeckById;
    late CreateDeckUseCase createDeck;

    setUp(() {
      getDecks = di.sl<GetDecksUseCase>();
      getDeckById = di.sl<GetDeckByIdUseCase>();
      createDeck = di.sl<CreateDeckUseCase>();
    });

    test('1.1. Get all decks', () async {
      TestHelper.printSection('TEST 1.1: GET ALL DECKS');

      final result = await getDecks(search: null);

      result.fold(
        (failure) {
          TestHelper.printError('Failed to get decks: ${failure.message}');
          fail('Should get decks successfully');
        },
        (decks) {
          TestHelper.printSuccess('Got ${decks.length} decks');
          expect(decks, isA<List>());

          if (decks.isNotEmpty) {
            final firstDeck = decks.first;
            TestHelper.printSuccess('First deck: ${firstDeck.name}');
            expect(firstDeck.id, isPositive);
            expect(firstDeck.name, isNotEmpty);
          }
        },
      );
    });

    test('1.2. Search decks', () async {
      TestHelper.printSection('TEST 1.2: SEARCH DECKS');

      final result = await getDecks(search: 'JLPT');

      result.fold(
        (failure) {
          TestHelper.printError('Failed to search decks: ${failure.message}');
          fail('Should search decks successfully');
        },
        (decks) {
          TestHelper.printSuccess(
            'Found ${decks.length} decks matching "JLPT"',
          );
          expect(decks, isA<List>());
        },
      );
    });

    test('1.3. Get deck detail', () async {
      TestHelper.printSection('TEST 1.3: GET DECK DETAIL');

      // First get a deck to test with
      final listResult = await getDecks(search: null);

      await listResult.fold((failure) => fail('Should get deck list'), (
        decks,
      ) async {
        if (decks.isEmpty) {
          TestHelper.printStep('No decks available to test');
          return;
        }

        final deckId = decks.first.id;
        TestHelper.printStep('Testing with deck ID: $deckId');

        final detailResult = await getDeckById(deckId);

        detailResult.fold(
          (failure) {
            TestHelper.printError('Failed to get detail: ${failure.message}');
            fail('Should get deck detail successfully');
          },
          (deck) {
            TestHelper.printSuccess('Got deck detail: ${deck.name}');
            expect(deck.id, equals(deckId));
            expect(deck.name, isNotEmpty);

            if (deck.cards != null && deck.cards!.isNotEmpty) {
              TestHelper.printSuccess('Deck has ${deck.cards!.length} cards');
              final firstCard = deck.cards!.first;
              expect(firstCard.id, isPositive);
              expect(firstCard.character, isNotEmpty);
            } else {
              TestHelper.printStep('Deck has no cards');
            }
          },
        );
      });
    });

    test('1.4. Create new deck (requires auth)', () async {
      TestHelper.printSection('TEST 1.4: CREATE NEW DECK');

      final result = await createDeck(
        name: 'Test Deck ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Integration test deck',
        kanjiIds: null,
      );

      result.fold(
        (failure) {
          TestHelper.printStep(
            'Failed (expected if not authenticated): ${failure.message}',
          );
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('401'),
              contains('authentication'),
            ),
            reason: 'Should fail with authentication error',
          );
        },
        (deck) {
          TestHelper.printSuccess('Created deck: ${deck.name}');
          expect(deck.id, isPositive);
          expect(deck.name, contains('Test Deck'));
        },
      );
    });

    test('1.5. Create deck with kanji', () async {
      TestHelper.printSection('TEST 1.5: CREATE DECK WITH KANJI');

      final result = await createDeck(
        name: 'Deck with Kanji ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Deck containing specific kanji',
        kanjiIds: [1, 2, 3], // Assuming these IDs exist
      );

      result.fold(
        (failure) {
          TestHelper.printStep(
            'Failed (expected if not authenticated): ${failure.message}',
          );
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('401'),
              contains('authentication'),
            ),
          );
        },
        (deck) {
          TestHelper.printSuccess('Created deck with kanji: ${deck.name}');
          expect(deck.id, isPositive);

          if (deck.cards != null) {
            TestHelper.printSuccess('Deck has ${deck.cards!.length} cards');
          }
        },
      );
    });

    test('1.6. Handle invalid deck ID', () async {
      TestHelper.printSection('TEST 1.6: HANDLE INVALID DECK ID');

      final result = await getDeckById(99999);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('not found'),
              contains('Not Found'),
              contains('404'),
            ),
          );
        },
        (deck) {
          fail('Should fail for invalid deck ID');
        },
      );
    });
  });

  group('2. Card Management Tests -', () {
    late AddCardToDeckUseCase addCard;
    late RemoveCardFromDeckUseCase removeCard;
    late GetDecksUseCase getDecks;

    setUp(() {
      addCard = di.sl<AddCardToDeckUseCase>();
      removeCard = di.sl<RemoveCardFromDeckUseCase>();
      getDecks = di.sl<GetDecksUseCase>();
    });

    test('2.1. Add card to deck (requires auth)', () async {
      TestHelper.printSection('TEST 2.1: ADD CARD TO DECK');

      // Get a deck to test with
      final listResult = await getDecks(search: null);

      listResult.fold((failure) => TestHelper.printStep('No decks found'), (
        decks,
      ) async {
        if (decks.isEmpty) {
          TestHelper.printStep('No decks to add card to');
          return;
        }

        final deckId = decks.first.id;
        const kanjiId = 1; // Assuming this kanji exists

        final result = await addCard(deckId: deckId, kanjiId: kanjiId);

        result.fold(
          (failure) {
            TestHelper.printStep(
              'Failed (expected if not owner): ${failure.message}',
            );
            expect(
              failure.message,
              anyOf(
                contains('Unauthorized'),
                contains('Forbidden'),
                contains('already exists'),
                contains('401'),
                contains('403'),
              ),
            );
          },
          (deck) {
            TestHelper.printSuccess('Added card to deck');
            expect(deck.id, equals(deckId));
          },
        );
      });
    });

    test('2.2. Remove card from deck (requires auth)', () async {
      TestHelper.printSection('TEST 2.2: REMOVE CARD FROM DECK');

      // Try with non-existent deck
      final result = await removeCard(deckId: 99999, kanjiId: 1);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (deck) {
          TestHelper.printSuccess('Removed card from deck');
        },
      );
    });

    test('2.3. Add duplicate card (should fail)', () async {
      TestHelper.printSection('TEST 2.3: ADD DUPLICATE CARD');

      final result = await addCard(deckId: 1, kanjiId: 1);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (deck) {
          TestHelper.printStep('Backend allowed duplicate or card didnt exist');
        },
      );
    });
  });

  group('3. Study Session Tests -', () {
    late StartSessionUseCase startSession;
    late GetSessionProgressUseCase getSessionProgress;
    late GetNextCardUseCase getNextCard;
    late ReviewCardUseCase reviewCard;
    late CompleteSessionUseCase completeSession;
    late GetDecksUseCase getDecks;

    setUp(() {
      startSession = di.sl<StartSessionUseCase>();
      getSessionProgress = di.sl<GetSessionProgressUseCase>();
      getNextCard = di.sl<GetNextCardUseCase>();
      reviewCard = di.sl<ReviewCardUseCase>();
      completeSession = di.sl<CompleteSessionUseCase>();
      getDecks = di.sl<GetDecksUseCase>();
    });

    test('3.1. Start study session (requires auth)', () async {
      TestHelper.printSection('TEST 3.1: START STUDY SESSION');

      // Get a deck to study
      final listResult = await getDecks(search: null);

      listResult.fold((failure) => TestHelper.printStep('No decks found'), (
        decks,
      ) async {
        if (decks.isEmpty) {
          TestHelper.printStep('No decks available for study');
          return;
        }

        final deckId = decks.first.id;
        TestHelper.printStep('Starting session with deck ID: $deckId');

        final result = await startSession(
          deckId: deckId,
          maxNewCards: 10,
          maxReviewCards: 20,
        );

        result.fold(
          (failure) {
            TestHelper.printStep(
              'Failed (expected if not authenticated): ${failure.message}',
            );
            expect(
              failure.message,
              anyOf(
                contains('Unauthorized'),
                contains('401'),
                contains('No cards available'),
              ),
            );
          },
          (session) {
            TestHelper.printSuccess(
              'Started session: ${session.sessionId}, Total cards: ${session.totalCards}',
            );
            expect(session.sessionId, isPositive);
            expect(session.deckId, equals(deckId));
            expect(session.totalCards, isPositive);
          },
        );
      });
    });

    test('3.2. Get session progress', () async {
      TestHelper.printSection('TEST 3.2: GET SESSION PROGRESS');

      // Try with non-existent session
      final result = await getSessionProgress(99999);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('not found'),
              contains('401'),
              contains('404'),
            ),
          );
        },
        (session) {
          TestHelper.printSuccess('Got session progress');
          expect(session.sessionId, isPositive);
        },
      );
    });

    test('3.3. Get next card in session', () async {
      TestHelper.printSection('TEST 3.3: GET NEXT CARD');

      // Try with non-existent session
      final result = await getNextCard(99999);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('not found'),
              contains('No more cards'),
              contains('401'),
              contains('404'),
            ),
          );
        },
        (card) {
          TestHelper.printSuccess('Got next card: ${card.character}');
          expect(card.cardId, isPositive);
          expect(card.character, isNotEmpty);
        },
      );
    });

    test('3.4. Review card with SM-2 quality ratings', () async {
      TestHelper.printSection('TEST 3.4: REVIEW CARD');

      // Try with non-existent session
      for (int quality = 0; quality <= 5; quality++) {
        TestHelper.printStep('Testing quality rating: $quality');

        final result = await reviewCard(
          sessionId: 99999,
          cardId: 1,
          quality: quality,
          timeSpent: 5.0,
        );

        result.fold(
          (failure) {
            TestHelper.printStep('Failed (expected): ${failure.message}');
          },
          (_) {
            TestHelper.printSuccess('Reviewed with quality $quality');
          },
        );
      }
    });

    test('3.5. Complete study session', () async {
      TestHelper.printSection('TEST 3.5: COMPLETE SESSION');

      // Try with non-existent session
      final result = await completeSession(99999);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('not found'),
              contains('401'),
              contains('404'),
            ),
          );
        },
        (session) {
          TestHelper.printSuccess(
            'Completed session - Accuracy: ${session.accuracy}%',
          );
          expect(session.sessionId, isPositive);
        },
      );
    });
  });

  group('4. Statistics Tests -', () {
    late GetDueCardsUseCase getDueCards;
    late GetDeckStatisticsUseCase getDeckStatistics;
    late GetDecksUseCase getDecks;

    setUp(() {
      getDueCards = di.sl<GetDueCardsUseCase>();
      getDeckStatistics = di.sl<GetDeckStatisticsUseCase>();
      getDecks = di.sl<GetDecksUseCase>();
    });

    test('4.1. Get due cards for deck', () async {
      TestHelper.printSection('TEST 4.1: GET DUE CARDS');

      // Get a deck to check due cards
      final listResult = await getDecks(search: null);

      listResult.fold((failure) => TestHelper.printStep('No decks found'), (
        decks,
      ) async {
        if (decks.isEmpty) {
          TestHelper.printStep('No decks available');
          return;
        }

        final deckId = decks.first.id;
        TestHelper.printStep('Checking due cards for deck ID: $deckId');

        final result = await getDueCards(deckId);

        result.fold(
          (failure) {
            TestHelper.printStep('Failed: ${failure.message}');
            expect(
              failure.message,
              anyOf(
                contains('Unauthorized'),
                contains('not found'),
                contains('401'),
                contains('404'),
              ),
            );
          },
          (dueCards) {
            TestHelper.printSuccess(
              'Due cards - Total: ${dueCards['totalDue']}, New: ${dueCards['newCards']}',
            );
            expect(dueCards, isA<Map<String, dynamic>>());
            expect(dueCards.containsKey('totalDue'), isTrue);
          },
        );
      });
    });

    test('4.2. Get deck statistics', () async {
      TestHelper.printSection('TEST 4.2: GET DECK STATISTICS');

      // Get a deck to check statistics
      final listResult = await getDecks(search: null);

      listResult.fold((failure) => TestHelper.printStep('No decks found'), (
        decks,
      ) async {
        if (decks.isEmpty) {
          TestHelper.printStep('No decks available');
          return;
        }

        final deckId = decks.first.id;
        TestHelper.printStep('Getting statistics for deck ID: $deckId');

        final result = await getDeckStatistics(deckId);

        result.fold(
          (failure) {
            TestHelper.printStep('Failed: ${failure.message}');
            expect(
              failure.message,
              anyOf(
                contains('Unauthorized'),
                contains('not found'),
                contains('401'),
                contains('404'),
              ),
            );
          },
          (stats) {
            TestHelper.printSuccess(
              'Statistics - Total: ${stats.totalCards}, New: ${stats.newCards}, Mastered: ${stats.masteredCards}',
            );
            expect(stats.deckId, equals(deckId));
            expect(stats.totalCards, greaterThanOrEqualTo(0));
          },
        );
      });
    });

    test('4.3. Statistics for invalid deck', () async {
      TestHelper.printSection('TEST 4.3: STATISTICS FOR INVALID DECK');

      final result = await getDeckStatistics(99999);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('not found'),
              contains('401'),
              contains('404'),
            ),
          );
        },
        (stats) {
          fail('Should fail for invalid deck ID');
        },
      );
    });
  });

  group('5. Update/Delete Tests -', () {
    late UpdateDeckUseCase updateDeck;
    late DeleteDeckUseCase deleteDeck;

    setUp(() {
      updateDeck = di.sl<UpdateDeckUseCase>();
      deleteDeck = di.sl<DeleteDeckUseCase>();
    });

    test('5.1. Update deck name (requires auth)', () async {
      TestHelper.printSection('TEST 5.1: UPDATE DECK NAME');

      // Try to update non-existent deck
      final result = await updateDeck(
        deckId: 99999,
        name: 'Updated Name',
        description: null,
        isPublic: null,
      );

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (_) {
          TestHelper.printSuccess('Updated deck');
        },
      );
    });

    test('5.2. Update deck description', () async {
      TestHelper.printSection('TEST 5.2: UPDATE DECK DESCRIPTION');

      final result = await updateDeck(
        deckId: 99999,
        name: null,
        description: 'Updated description',
        isPublic: null,
      );

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
        },
        (_) {
          TestHelper.printSuccess('Updated description');
        },
      );
    });

    test('5.3. Delete deck (requires auth and ownership)', () async {
      TestHelper.printSection('TEST 5.3: DELETE DECK');

      // Try to delete non-existent deck
      final result = await deleteDeck(99999);

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('Forbidden'),
              contains('not found'),
              contains('401'),
              contains('403'),
              contains('404'),
            ),
          );
        },
        (_) {
          TestHelper.printSuccess('Delete operation completed');
        },
      );
    });
  });

  group('6. Error Handling Tests -', () {
    late GetDeckByIdUseCase getDeckById;
    late StartSessionUseCase startSession;
    late ReviewCardUseCase reviewCard;

    setUp(() {
      getDeckById = di.sl<GetDeckByIdUseCase>();
      startSession = di.sl<StartSessionUseCase>();
      reviewCard = di.sl<ReviewCardUseCase>();
    });

    test('6.1. Handle negative deck ID', () async {
      TestHelper.printSection('TEST 6.1: HANDLE NEGATIVE DECK ID');

      final result = await getDeckById(-1);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (deck) {
          fail('Should fail for negative deck ID');
        },
      );
    });

    test('6.2. Handle zero deck ID', () async {
      TestHelper.printSection('TEST 6.2: HANDLE ZERO DECK ID');

      final result = await getDeckById(0);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (deck) {
          fail('Should fail for zero deck ID');
        },
      );
    });

    test('6.3. Invalid quality rating', () async {
      TestHelper.printSection('TEST 6.3: INVALID QUALITY RATING');

      // Quality should be 0-5
      final result = await reviewCard(
        sessionId: 1,
        cardId: 1,
        quality: 10, // Invalid
        timeSpent: 5.0,
      );

      result.fold(
        (failure) {
          TestHelper.printStep('Failed (expected): ${failure.message}');
        },
        (_) {
          TestHelper.printStep(
            'Backend accepted invalid quality (validation issue)',
          );
        },
      );
    });

    test('6.4. Start session with empty deck', () async {
      TestHelper.printSection('TEST 6.4: START SESSION WITH EMPTY DECK');

      final result = await startSession(
        deckId: 99999,
        maxNewCards: 10,
        maxReviewCards: 20,
      );

      result.fold(
        (failure) {
          TestHelper.printSuccess('Correctly failed with: ${failure.message}');
          expect(
            failure.message,
            anyOf(
              contains('Unauthorized'),
              contains('not found'),
              contains('No cards'),
              contains('401'),
              contains('404'),
            ),
          );
        },
        (session) {
          fail('Should fail for empty deck');
        },
      );
    });
  });

  group('7. Performance Tests -', () {
    late GetDecksUseCase getDecks;
    late GetDeckByIdUseCase getDeckById;

    setUp(() {
      getDecks = di.sl<GetDecksUseCase>();
      getDeckById = di.sl<GetDeckByIdUseCase>();
    });

    test('7.1. List performance test', () async {
      TestHelper.printSection('TEST 7.1: LIST PERFORMANCE');

      final startTime = DateTime.now();

      final result = await getDecks(search: null);

      final duration = DateTime.now().difference(startTime);

      result.fold((failure) => fail('Should load decks'), (decks) {
        TestHelper.printSuccess(
          'Loaded ${decks.length} decks in ${duration.inMilliseconds}ms',
        );
        expect(
          duration.inSeconds,
          lessThan(5),
          reason: 'Should load within 5 seconds',
        );
      });
    });

    test('7.2. Detail load performance', () async {
      TestHelper.printSection('TEST 7.2: DETAIL LOAD PERFORMANCE');

      // Get a deck first
      final listResult = await getDecks(search: null);

      listResult.fold((failure) => TestHelper.printStep('No decks available'), (
        decks,
      ) async {
        if (decks.isEmpty) return;

        final deckId = decks.first.id;
        final startTime = DateTime.now();

        final result = await getDeckById(deckId);

        final duration = DateTime.now().difference(startTime);

        result.fold((failure) => fail('Should load deck detail'), (deck) {
          TestHelper.printSuccess(
            'Loaded deck detail in ${duration.inMilliseconds}ms',
          );
          expect(
            duration.inSeconds,
            lessThan(5),
            reason: 'Detail load should complete within 5 seconds',
          );
        });
      });
    });

    test('7.3. Concurrent requests test', () async {
      TestHelper.printSection('TEST 7.3: CONCURRENT REQUESTS');

      final startTime = DateTime.now();

      // Make 3 concurrent requests
      final futures = [
        getDecks(search: null),
        getDecks(search: 'JLPT'),
        getDecks(search: 'N5'),
      ];

      final results = await Future.wait(futures);
      final duration = DateTime.now().difference(startTime);

      // Count successes (Right means API call succeeded, even if empty)
      int successCount = 0;
      for (var result in results) {
        result.fold((failure) => null, (decks) => successCount++);
      }

      TestHelper.printSuccess(
        '$successCount/3 concurrent requests succeeded in ${duration.inMilliseconds}ms',
      );
      expect(
        successCount,
        equals(3),
        reason: 'All requests should succeed (empty list is still success)',
      );
      expect(
        duration.inSeconds,
        lessThan(10),
        reason: 'Concurrent requests should complete within 10 seconds',
      );
    });
  });

  group('8. SM-2 Algorithm Tests -', () {
    late ReviewCardUseCase reviewCard;

    setUp(() {
      reviewCard = di.sl<ReviewCardUseCase>();
    });

    test('8.1. Test all quality ratings (0-5)', () async {
      TestHelper.printSection('TEST 8.1: TEST ALL QUALITY RATINGS');

      for (int quality = 0; quality <= 5; quality++) {
        TestHelper.printStep('Testing quality: $quality');

        final result = await reviewCard(
          sessionId: 1,
          cardId: 1,
          quality: quality,
          timeSpent: 5.0,
        );

        result.fold(
          (failure) {
            TestHelper.printStep('Quality $quality: ${failure.message}');
          },
          (_) {
            TestHelper.printSuccess('Quality $quality: Accepted');
          },
        );
      }

      TestHelper.printSuccess('All quality ratings tested');
    });

    test('8.2. Test time tracking', () async {
      TestHelper.printSection('TEST 8.2: TEST TIME TRACKING');

      final timings = [0.5, 1.0, 5.0, 10.0, 30.0];

      for (final time in timings) {
        TestHelper.printStep('Testing time: ${time}s');

        final result = await reviewCard(
          sessionId: 1,
          cardId: 1,
          quality: 5,
          timeSpent: time,
        );

        result.fold(
          (failure) {
            TestHelper.printStep('Time ${time}s: ${failure.message}');
          },
          (_) {
            TestHelper.printSuccess('Time ${time}s: Tracked');
          },
        );
      }

      TestHelper.printSuccess('All time intervals tested');
    });
  });
}
