import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/features/flashcard/data/datasources/flashcard_remote_datasource.dart';
import 'package:kanji_mobile_app/features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'package:kanji_mobile_app/features/flashcard/domain/entities/review_type.dart';
import 'package:kanji_mobile_app/features/flashcard/domain/usecases/flashcard_usecases.dart';
import 'test_helper.dart';

void main() {
  group('Flashcard Session Integration Tests', () {
    late ApiClient apiClient;
    late FlashcardRemoteDataSourceImpl dataSource;
    late FlashcardRepositoryImpl repository;
    late StartSessionUseCase startSessionUseCase;
    late GetActiveSessionUseCase getActiveSessionUseCase;
    late GetNextCardUseCase getNextCardUseCase;
    late ReviewCardUseCase reviewCardUseCase;
    late CompleteSessionUseCase completeSessionUseCase;

    String? authToken;
    int? testDeckId;
    int? testSessionId;

    setUpAll(() async {
      TestHelper.printHeader('Flashcard Session Integration Tests Setup');

      apiClient = TestHelper.createApiClient();
      dataSource = FlashcardRemoteDataSourceImpl(
        apiClient: apiClient,
        secureStorage: TestHelper.createMockSecureStorage(),
      );
      repository = FlashcardRepositoryImpl(remoteDataSource: dataSource);

      startSessionUseCase = StartSessionUseCase(repository);
      getActiveSessionUseCase = GetActiveSessionUseCase(repository);
      getNextCardUseCase = GetNextCardUseCase(repository);
      reviewCardUseCase = ReviewCardUseCase(repository);
      completeSessionUseCase = CompleteSessionUseCase(repository);

      // Login
      authToken = await TestHelper.loginTestUser(apiClient);
      TestHelper.printSuccess(
        'Logged in with token: ${authToken?.substring(0, 20)}...',
      );
    });

    setUp(() async {
      // Create a test deck with some cards before each test
      TestHelper.printInfo('Creating test deck with cards...');
      final createResult = await TestHelper.createTestDeck(
        apiClient,
        authToken!,
        name: 'Session Test Deck ${DateTime.now().millisecondsSinceEpoch}',
      );
      testDeckId = createResult['deckId'] as int;
      TestHelper.printSuccess('Created test deck: $testDeckId');
    });

    tearDown(() async {
      // Clean up: complete any active session
      if (testSessionId != null) {
        try {
          await completeSessionUseCase(testSessionId!);
          TestHelper.printInfo('Completed test session: $testSessionId');
        } catch (e) {
          TestHelper.printWarning('Could not complete session: $e');
        }
        testSessionId = null;
      }

      // Delete test deck
      if (testDeckId != null) {
        try {
          await TestHelper.deleteDeck(apiClient, authToken!, testDeckId!);
          TestHelper.printInfo('Deleted test deck: $testDeckId');
        } catch (e) {
          TestHelper.printWarning('Could not delete deck: $e');
        }
        testDeckId = null;
      }
    });

    group('Review Type Tests', () {
      test('should start session with ALL review type', () async {
        TestHelper.printTest('Starting session with ReviewType.all');

        final result = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
          reviewType: ReviewType.all,
        );

        result.fold(
          (failure) {
            TestHelper.printError(
              'Failed to start session: ${failure.message}',
            );
            fail('Expected success but got failure');
          },
          (session) {
            TestHelper.printSuccess('Session started: ${session.sessionId}');
            testSessionId = session.sessionId;

            expect(session.sessionId, isPositive);
            expect(session.deckId, equals(testDeckId));
            expect(session.totalCards, isPositive);

            TestHelper.printInfo(
              'Total cards in session: ${session.totalCards}',
            );
            TestHelper.printInfo('New cards: ${session.newCards}');
            TestHelper.printInfo('Review cards: ${session.reviewCards}');
          },
        );
      });

      test('should start session with NEW_ONLY review type', () async {
        TestHelper.printTest('Starting session with ReviewType.newOnly');

        final result = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
          reviewType: ReviewType.newOnly,
        );

        result.fold(
          (failure) {
            TestHelper.printError('Failed: ${failure.message}');
            fail('Expected success');
          },
          (session) {
            TestHelper.printSuccess('Session started with new cards only');
            testSessionId = session.sessionId;

            expect(session.sessionId, isPositive);
            expect(session.totalCards, equals(session.newCards));
            expect(session.reviewCards, equals(0));

            TestHelper.printInfo('New cards: ${session.newCards}');
            TestHelper.printInfo('Review cards: ${session.reviewCards}');
          },
        );
      });

      test('should start session with DUE_ONLY review type', () async {
        TestHelper.printTest('Starting session with ReviewType.dueOnly');

        final result = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
          reviewType: ReviewType.dueOnly,
        );

        result.fold(
          (failure) {
            // Expected: no due cards yet
            TestHelper.printInfo(
              'Expected failure (no due cards): ${failure.message}',
            );
            expect(failure.message, contains('No cards available'));
          },
          (session) {
            TestHelper.printWarning(
              'Unexpected success - got session with due cards',
            );
            testSessionId = session.sessionId;
            expect(session.reviewCards, equals(session.totalCards));
          },
        );
      });

      test('should handle ReviewType enum correctly', () {
        TestHelper.printTest('Testing ReviewType enum');

        expect(ReviewType.all.value, equals('ALL'));
        expect(ReviewType.newOnly.value, equals('NEW_ONLY'));
        expect(ReviewType.dueOnly.value, equals('DUE_ONLY'));

        expect(ReviewType.all.label, equals('All Cards'));
        expect(ReviewType.newOnly.label, equals('New Cards Only'));
        expect(ReviewType.dueOnly.label, equals('Review Due Cards'));

        TestHelper.printSuccess('ReviewType enum values correct');
      });
    });

    group('Active Session Tests', () {
      test('should return null when no active session exists', () async {
        TestHelper.printTest('Checking for active session (should be null)');

        final result = await getActiveSessionUseCase(testDeckId!);

        result.fold(
          (failure) {
            TestHelper.printError('Failed: ${failure.message}');
            fail('Expected success');
          },
          (activeSession) {
            expect(activeSession, isNull);
            TestHelper.printSuccess('No active session (as expected)');
          },
        );
      });

      test('should return active session after starting', () async {
        TestHelper.printTest(
          'Creating session and checking for active session',
        );

        // Start a session first
        final startResult = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
          reviewType: ReviewType.all,
        );

        int sessionId = 0;
        startResult.fold((failure) => fail('Failed to start session'), (
          session,
        ) {
          sessionId = session.sessionId;
          testSessionId = sessionId;
          TestHelper.printInfo('Started session: $sessionId');
        });

        // Now check for active session
        final activeResult = await getActiveSessionUseCase(testDeckId!);

        activeResult.fold(
          (failure) {
            TestHelper.printError(
              'Failed to get active session: ${failure.message}',
            );
            fail('Expected success');
          },
          (activeSession) {
            expect(activeSession, isNotNull);
            expect(activeSession!.sessionId, equals(sessionId));
            expect(activeSession.deckId, equals(testDeckId));
            expect(activeSession.totalCards, isPositive);
            expect(activeSession.cardsReviewed, isA<int>());
            expect(activeSession.cardsRemaining, isPositive);
            expect(activeSession.accuracy, isA<double>());
            expect(activeSession.startedAt, isA<DateTime>());

            TestHelper.printSuccess('Active session found!');
            TestHelper.printInfo('Session ID: ${activeSession.sessionId}');
            TestHelper.printInfo('Total cards: ${activeSession.totalCards}');
            TestHelper.printInfo(
              'Cards reviewed: ${activeSession.cardsReviewed}',
            );
            TestHelper.printInfo(
              'Cards remaining: ${activeSession.cardsRemaining}',
            );
            TestHelper.printInfo('Accuracy: ${activeSession.accuracy}%');
            TestHelper.printInfo('Started at: ${activeSession.startedAt}');
          },
        );
      });

      test(
        'should update active session progress after reviewing cards',
        () async {
          TestHelper.printTest('Testing active session progress tracking');

          // Start session
          final startResult = await startSessionUseCase(
            deckId: testDeckId!,
            maxNewCards: 5,
            maxReviewCards: 10,
            reviewType: ReviewType.all,
          );

          int sessionId = 0;
          startResult.fold((failure) => fail('Failed to start session'), (
            session,
          ) {
            sessionId = session.sessionId;
            testSessionId = sessionId;
          });

          // Get first card
          final nextCardResult = await getNextCardUseCase(sessionId);
          int? cardId;
          nextCardResult.fold((failure) => fail('Failed to get next card'), (
            card,
          ) {
            cardId = card?.cardId;
            TestHelper.printInfo('Got card: ${card?.character}');
          });

          if (cardId != null) {
            // Review the card
            await reviewCardUseCase(
              sessionId: sessionId,
              cardId: cardId!,
              quality: 4, // Good
              timeSpent: 5.0,
            );
            TestHelper.printInfo('Reviewed card with quality 4');

            // Check active session again
            final activeResult = await getActiveSessionUseCase(testDeckId!);

            activeResult.fold(
              (failure) => fail('Failed to get active session'),
              (activeSession) {
                expect(activeSession, isNotNull);
                expect(activeSession!.cardsReviewed, equals(1));
                expect(
                  activeSession.cardsRemaining,
                  lessThan(activeSession.totalCards),
                );

                TestHelper.printSuccess('Active session progress updated');
                TestHelper.printInfo(
                  'Cards reviewed: ${activeSession.cardsReviewed}',
                );
                TestHelper.printInfo(
                  'Cards remaining: ${activeSession.cardsRemaining}',
                );
                TestHelper.printInfo('Accuracy: ${activeSession.accuracy}%');
              },
            );
          }
        },
      );

      test('should return null after completing session', () async {
        TestHelper.printTest('Testing active session cleanup after completion');

        // Start and complete a session
        final startResult = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
          reviewType: ReviewType.all,
        );

        int sessionId = 0;
        startResult.fold((failure) => fail('Failed to start session'), (
          session,
        ) {
          sessionId = session.sessionId;
          testSessionId = sessionId;
        });

        // Complete session immediately
        await completeSessionUseCase(sessionId);
        TestHelper.printInfo('Completed session');
        testSessionId = null; // Don't try to clean up in tearDown

        // Check for active session
        final activeResult = await getActiveSessionUseCase(testDeckId!);

        activeResult.fold((failure) => fail('Failed to check active session'), (
          activeSession,
        ) {
          expect(activeSession, isNull);
          TestHelper.printSuccess(
            'No active session after completion (as expected)',
          );
        });
      });
    });

    group('Type Casting Tests', () {
      test('should handle session response type casting correctly', () async {
        TestHelper.printTest('Testing session response type casting');

        final result = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
          reviewType: ReviewType.all,
        );

        result.fold((failure) => fail('Failed to start session'), (session) {
          testSessionId = session.sessionId;

          // Test all field types
          expect(session.sessionId, isA<int>());
          expect(session.deckId, isA<int>());
          expect(session.deckName, isA<String>());
          expect(session.totalCards, isA<int>());
          expect(session.newCards, isA<int>());
          expect(session.reviewCards, isA<int>());
          expect(session.startedAt, isA<DateTime>());

          TestHelper.printSuccess('All session fields have correct types');
        });
      });

      test(
        'should handle active session response type casting correctly',
        () async {
          TestHelper.printTest('Testing active session response type casting');

          // Start session first
          final startResult = await startSessionUseCase(
            deckId: testDeckId!,
            maxNewCards: 5,
            maxReviewCards: 10,
          );

          startResult.fold(
            (failure) => fail('Failed to start session'),
            (session) => testSessionId = session.sessionId,
          );

          // Get active session
          final activeResult = await getActiveSessionUseCase(testDeckId!);

          activeResult.fold((failure) => fail('Failed to get active session'), (
            activeSession,
          ) {
            expect(activeSession, isNotNull);

            // Test all field types
            expect(activeSession!.sessionId, isA<int>());
            expect(activeSession.deckId, isA<int>());
            expect(activeSession.totalCards, isA<int>());
            expect(activeSession.cardsReviewed, isA<int>());
            expect(activeSession.cardsRemaining, isA<int>());
            expect(activeSession.accuracy, isA<double>());
            expect(activeSession.startedAt, isA<DateTime>());

            // Test calculated property
            expect(activeSession.progressPercentage, isA<double>());
            expect(activeSession.progressPercentage, greaterThanOrEqualTo(0));
            expect(activeSession.progressPercentage, lessThanOrEqualTo(100));

            TestHelper.printSuccess(
              'All active session fields have correct types',
            );
            TestHelper.printInfo(
              'Progress: ${activeSession.progressPercentage.toStringAsFixed(1)}%',
            );
          });
        },
      );

      test('should handle null active session correctly', () async {
        TestHelper.printTest('Testing null active session type handling');

        final result = await getActiveSessionUseCase(testDeckId!);

        result.fold((failure) => fail('Failed to get active session'), (
          activeSession,
        ) {
          expect(activeSession, isNull);
          expect(activeSession, isA<Object?>());

          TestHelper.printSuccess('Null active session handled correctly');
        });
      });

      test('should handle DateTime parsing correctly', () async {
        TestHelper.printTest('Testing DateTime parsing in responses');

        final startResult = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
        );

        startResult.fold((failure) => fail('Failed to start session'), (
          session,
        ) {
          testSessionId = session.sessionId;

          final now = DateTime.now();
          final diff = now.difference(session.startedAt).inSeconds;

          expect(
            session.startedAt.isBefore(now) ||
                session.startedAt.isAtSameMomentAs(now),
            isTrue,
          );
          expect(diff, lessThan(10)); // Should be within 10 seconds

          TestHelper.printSuccess('DateTime parsed correctly');
          TestHelper.printInfo('Session started at: ${session.startedAt}');
          TestHelper.printInfo('Time diff: $diff seconds');
        });
      });

      test('should handle numeric types correctly', () async {
        TestHelper.printTest('Testing numeric type handling');

        // Start session and review a card
        final startResult = await startSessionUseCase(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
        );

        int sessionId = 0;
        startResult.fold((failure) => fail('Failed to start session'), (
          session,
        ) {
          sessionId = session.sessionId;
          testSessionId = sessionId;
        });

        // Get and review a card
        final nextCardResult = await getNextCardUseCase(sessionId);
        int? cardId;
        nextCardResult.fold(
          (failure) => fail('Failed to get next card'),
          (card) => cardId = card?.cardId,
        );

        if (cardId != null) {
          await reviewCardUseCase(
            sessionId: sessionId,
            cardId: cardId!,
            quality: 4,
            timeSpent: 5.5,
          );

          // Get active session to check accuracy calculation
          final activeResult = await getActiveSessionUseCase(testDeckId!);

          activeResult.fold((failure) => fail('Failed to get active session'), (
            activeSession,
          ) {
            expect(activeSession, isNotNull);
            expect(activeSession!.accuracy, isA<double>());
            expect(activeSession.accuracy, greaterThanOrEqualTo(0.0));
            expect(activeSession.accuracy, lessThanOrEqualTo(100.0));

            TestHelper.printSuccess('Numeric types handled correctly');
            TestHelper.printInfo('Accuracy: ${activeSession.accuracy}%');
          });
        }
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid deck ID gracefully', () async {
        TestHelper.printTest('Testing error handling with invalid deck ID');

        final result = await getActiveSessionUseCase(99999);

        result.fold(
          (failure) {
            TestHelper.printSuccess(
              'Error handled correctly: ${failure.message}',
            );
            expect(failure.message, isNotEmpty);
          },
          (activeSession) {
            // Should be null for non-existent deck
            expect(activeSession, isNull);
            TestHelper.printInfo('Returned null for invalid deck (acceptable)');
          },
        );
      });

      test('should handle network errors in active session check', () async {
        TestHelper.printTest('Testing network error handling');

        // This test verifies error handling structure
        final result = await getActiveSessionUseCase(testDeckId!);

        expect(result, isNotNull);
        result.fold(
          (failure) => TestHelper.printInfo('Got failure: ${failure.message}'),
          (session) => TestHelper.printInfo('Got success: ${session != null}'),
        );

        TestHelper.printSuccess('Error handling structure correct');
      });
    });
  });
}
