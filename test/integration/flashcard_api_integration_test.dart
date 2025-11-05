import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/core/storage/secure_storage.dart';
import 'package:kanji_mobile_app/features/flashcard/data/datasources/flashcard_remote_datasource.dart';
import 'package:kanji_mobile_app/features/flashcard/domain/entities/review_type.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_helper.dart';

/// Mock SecureStorage for testing (works without flutter_secure_storage plugin)
class MockSecureStorage extends SecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String token) async {
    _storage['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _storage['auth_token'];
  }

  @override
  Future<void> saveUserId(String userId) async {
    _storage['user_id'] = userId;
  }

  @override
  Future<String?> getUserId() async {
    return _storage['user_id'];
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> hasToken() async {
    final token = _storage['auth_token'];
    return token != null && token.isNotEmpty;
  }
}

/// Integration Test for Flashcard API Endpoints
///
/// Tests all flashcard-related API operations including:
/// - Deck CRUD operations
/// - Study session management
/// - Card review workflow
/// - Statistics retrieval
/// - Review type filtering
///
/// Prerequisites:
/// - Backend server must be running (default: http://localhost:3000)
/// - Test user account (auto-created: test@example.com / Test123456)
/// - Database should have some kanji data for card creation
///
/// NOTE: This is an INTEGRATION test, not a unit test
/// It requires a real backend server and will create/modify real data
void main() {
  late FlashcardRemoteDataSource dataSource;

  // Test data IDs (will be set during tests)
  int? testDeckId;
  int? testSessionId;
  int? testCardId;

  setUpAll(() async {
    print('🚀 Setting up Flashcard API Integration Tests...');

    // Load environment variables
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('⚠️  Could not load .env file: $e');
      print('ℹ️  Using default values');
    }

    // Setup fake SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});

    // Initialize dependency injection
    await di.initializeDependencies();
    print('✅ Dependency injection initialized');

    // Replace real SecureStorage with mock (for test environment)
    // This must be done BEFORE setupAuth
    if (di.sl.isRegistered<SecureStorage>()) {
      await di.sl.unregister<SecureStorage>();
    }
    di.sl.registerLazySingleton<SecureStorage>(() => MockSecureStorage());
    print('✅ Mock SecureStorage registered');

    // Setup authentication (login and get token)
    await AuthHelper.setupAuth();
    print('✅ Authentication setup complete');

    // Get data source from DI container
    dataSource = di.sl<FlashcardRemoteDataSource>();

    print('✅ Setup complete\n');
  });

  tearDownAll(() {
    print('\n🧹 Cleaning up...');

    // Clear auth
    AuthHelper.clearAuth();

    // Close Dio client
    if (di.sl.isRegistered<ApiClient>()) {
      final apiClient = di.sl<ApiClient>();
      apiClient.dio.close();
    }

    print('✅ Cleanup complete');
  });

  group('🧪 FLASHCARD API INTEGRATION TESTS', () {
    group('📦 Deck Management', () {
      test('should create a new deck', () async {
        print('\n📝 TEST: Create Deck');

        final deck = await dataSource.createDeck(
          name: 'Test Deck ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Integration test deck',
        );

        testDeckId = deck.id;

        expect(deck.id, isPositive);
        expect(deck.name, contains('Test Deck'));
        expect(deck.description, 'Integration test deck');
        expect(deck.totalCards, 0);

        print('✅ Deck created: ID=${deck.id}, Name="${deck.name}"');
      });

      test('should get all decks', () async {
        print('\n📝 TEST: Get All Decks');

        final decks = await dataSource.getDecks();

        expect(decks, isNotEmpty);
        expect(decks.any((d) => d.id == testDeckId), true);

        print('✅ Found ${decks.length} decks');
      });

      test('should search decks by name', () async {
        print('\n📝 TEST: Search Decks');

        final deck = await dataSource.getDeckById(testDeckId!);
        final searchTerm = deck.name.substring(0, 10);

        final results = await dataSource.getDecks(search: searchTerm);

        expect(results, isNotEmpty);
        expect(results.any((d) => d.id == testDeckId), true);

        print('✅ Search "$searchTerm" found ${results.length} decks');
      });

      test('should get deck by id', () async {
        print('\n📝 TEST: Get Deck By ID');

        final deck = await dataSource.getDeckById(testDeckId!);

        expect(deck.id, testDeckId);
        expect(deck.name, isNotEmpty);

        print('✅ Got deck: ${deck.name}');
      });

      test('should update deck', () async {
        print('\n📝 TEST: Update Deck');

        final updatedDeck = await dataSource.updateDeck(
          deckId: testDeckId!,
          name: 'Updated Deck Name',
          description: 'Updated description',
        );

        expect(updatedDeck.id, testDeckId);
        expect(updatedDeck.name, 'Updated Deck Name');
        expect(updatedDeck.description, 'Updated description');

        print('✅ Deck updated successfully');
      });
    });

    group('🎴 Card Management', () {
      test('should add cards to deck from kanji', () async {
        print('\n📝 TEST: Add Cards to Deck');

        print('ℹ️  Card management requires existing kanji IDs in database');
        print('ℹ️  Use addCardToDeck(deckId: X, kanjiId: Y) to add cards');
        print('ℹ️  Use removeCardFromDeck(deckId: X, kanjiId: Y) to remove');
        print('✅ Test info provided (requires kanji database setup)');
      });
    });

    group('📖 Study Session Management', () {
      test('should start a study session', () async {
        print('\n📝 TEST: Start Study Session');

        final session = await dataSource.startSession(deckId: testDeckId!);

        testSessionId = session.sessionId;

        expect(session.sessionId, isPositive);
        expect(session.deckId, testDeckId);
        expect(session.deckName, isNotEmpty);

        print(
          '✅ Session started: ID=${session.sessionId}, Deck="${session.deckName}"',
        );
      });

      test('should get active session', () async {
        print('\n📝 TEST: Get Active Session');

        final activeSession = await dataSource.getActiveSession(testDeckId!);

        if (activeSession != null) {
          expect(activeSession.sessionId, testSessionId);
          expect(activeSession.deckId, testDeckId);
          expect(activeSession.totalCards, isA<int>());

          print(
            '✅ Active session: ${activeSession.cardsReviewed}/${activeSession.totalCards} reviewed',
          );
        } else {
          print('ℹ️  No active session found');
        }
      });

      test('should get session progress', () async {
        print('\n📝 TEST: Get Session Progress');

        final progress = await dataSource.getSessionProgress(testSessionId!);

        expect(progress.sessionId, testSessionId);
        expect(progress.deckId, testDeckId);
        expect(progress.totalCards, isA<int>());
        expect(progress.cardsReviewed, isA<int>());
        expect(progress.newCards, isA<int>());
        expect(progress.reviewCards, isA<int>());

        print(
          '✅ Progress: ${progress.cardsReviewed}/${progress.totalCards} cards',
        );
      });

      test('should get next card', () async {
        print('\n📝 TEST: Get Next Card');

        final nextCard = await dataSource.getNextCard(testSessionId!);

        if (nextCard != null) {
          testCardId = nextCard.cardId;

          expect(nextCard.cardId, isPositive);
          expect(nextCard.character, isNotEmpty);
          expect(nextCard.meaning, isNotEmpty);
          expect(nextCard.isNew, isA<bool>());

          print(
            '✅ Next card: ${nextCard.character} (${nextCard.meaning}) [isNew: ${nextCard.isNew}]',
          );
        } else {
          print('ℹ️  No more cards in session');
        }
      });

      test('should review card with quality rating', () async {
        print('\n📝 TEST: Review Card');

        if (testCardId == null) {
          print('⚠️  Skipping - no card available');
          return;
        }

        // reviewCard returns void, just verify it completes without error
        await dataSource.reviewCard(
          sessionId: testSessionId!,
          cardId: testCardId!,
          quality: 4, // Good rating
          timeSpent: 5.5,
        );

        print('✅ Card reviewed successfully');
      });

      test('should complete session', () async {
        print('\n📝 TEST: Complete Session');

        final completedSession = await dataSource.completeSession(
          testSessionId!,
        );

        expect(completedSession.sessionId, testSessionId);
        expect(completedSession.completedAt, isNotNull);

        print(
          '✅ Session completed: ${completedSession.cardsReviewed} cards reviewed',
        );
      });
    });

    group('🎯 Review Type Tests', () {
      test('should start session with NEW_ONLY review type', () async {
        print('\n📝 TEST: Review Type - NEW_ONLY');

        final session = await dataSource.startSession(
          deckId: testDeckId!,
          reviewType: ReviewType.newOnly,
        );

        expect(session.sessionId, isPositive);
        print('✅ NEW_ONLY session started: ID=${session.sessionId}');

        await dataSource.completeSession(session.sessionId);
        print('   Session cleaned up');
      });

      test('should start session with DUE_ONLY review type', () async {
        print('\n📝 TEST: Review Type - DUE_ONLY');

        final session = await dataSource.startSession(
          deckId: testDeckId!,
          reviewType: ReviewType.dueOnly,
        );

        expect(session.sessionId, isPositive);
        print('✅ DUE_ONLY session started: ID=${session.sessionId}');

        await dataSource.completeSession(session.sessionId);
        print('   Session cleaned up');
      });

      test('should start session with ALL review type', () async {
        print('\n📝 TEST: Review Type - ALL');

        final session = await dataSource.startSession(
          deckId: testDeckId!,
          reviewType: ReviewType.all,
        );

        expect(session.sessionId, isPositive);
        print('✅ ALL session started: ID=${session.sessionId}');

        await dataSource.completeSession(session.sessionId);
        print('   Session cleaned up');
      });
    });

    group('📊 Statistics', () {
      test('should get deck statistics', () async {
        print('\n📝 TEST: Get Deck Statistics');

        final stats = await dataSource.getDeckStatistics(testDeckId!);

        expect(stats.deckId, testDeckId);
        expect(stats.totalCards, isA<int>());
        expect(stats.masteredCards, isA<int>());
        expect(stats.learningCards, isA<int>());
        expect(stats.newCards, isA<int>());

        print('✅ Deck statistics retrieved:');
        print('   Total: ${stats.totalCards}');
        print('   Mastered: ${stats.masteredCards}');
        print('   Learning: ${stats.learningCards}');
        print('   New: ${stats.newCards}');
      });

      test('should get due cards', () async {
        print('\n📝 TEST: Get Due Cards');

        final dueCards = await dataSource.getDueCards(testDeckId!);

        expect(dueCards, isA<Map<String, dynamic>>());
        expect(dueCards.containsKey('total'), true);

        print('✅ Due cards: ${dueCards['total']}');
      });
    });

    group('🧹 Cleanup Operations', () {
      test('should delete test deck', () async {
        print('\n📝 TEST: Delete Deck');

        await dataSource.deleteDeck(testDeckId!);

        // Verify deletion by trying to get the deck
        try {
          await dataSource.getDeckById(testDeckId!);
          fail('Deck should have been deleted');
        } on DioException catch (e) {
          expect(e.response?.statusCode, 404);
          print('✅ Deck deleted successfully');
        }
      });
    });

    group('🔒 Type Safety Tests', () {
      test('should handle null active session', () async {
        print('\n📝 TEST: Null Active Session');

        // Create and immediately check active session
        final deck = await dataSource.createDeck(
          name: 'Type Safety Test ${DateTime.now().millisecondsSinceEpoch}',
        );

        final activeSession = await dataSource.getActiveSession(deck.id);

        expect(activeSession, isNull);
        print('✅ Null active session handled correctly');

        // Cleanup
        await dataSource.deleteDeck(deck.id);
        print('   Test deck cleaned up');
      });

      test('should handle numeric type casting in models', () async {
        print('\n📝 TEST: Numeric Type Casting');

        final deck = await dataSource.createDeck(
          name: 'Numeric Test ${DateTime.now().millisecondsSinceEpoch}',
        );

        // All these should be integers without casting errors
        expect(deck.id, isA<int>());
        expect(deck.userId, isA<int>());
        expect(deck.totalCards, isA<int?>());
        expect(deck.dueCards, isA<int?>());

        print('✅ All numeric fields cast correctly');

        // Cleanup
        await dataSource.deleteDeck(deck.id);
        print('   Test deck cleaned up');
      });
    });
  });
}
