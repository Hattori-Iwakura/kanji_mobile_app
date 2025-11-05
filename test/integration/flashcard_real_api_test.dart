import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/core/storage/secure_storage.dart';
import 'package:kanji_mobile_app/features/flashcard/data/datasources/flashcard_remote_datasource.dart';
import 'package:kanji_mobile_app/features/flashcard/domain/entities/review_type.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// REAL API INTEGRATION TEST
///
/// Prerequisites:
/// 1. Backend server MUST be running at localhost:3000
/// 2. Test user must exist: test@example.com / Test123456!
/// 3. Create .env file with: API_BASE_URL=http://localhost:3000/api
///
/// Run: flutter test test/integration/flashcard_real_api_test.dart
void main() {
  group('Real API Integration Tests', () {
    late ApiClient apiClient;
    late FlashcardRemoteDataSourceImpl dataSource;
    String? authToken;
    int? testDeckId;

    setUpAll(() async {
      print('\n' + '=' * 60);
      print('🔥 REAL API INTEGRATION TEST');
      print('=' * 60 + '\n');

      // Load environment
      try {
        await dotenv.load(fileName: '.env');
        print('✅ Loaded .env file');
      } catch (e) {
        print('⚠️  No .env file, using default URL');
      }

      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
      print('📡 Backend URL: $baseUrl\n');

      // Create API client using production constructor
      apiClient = ApiClient();

      // Create secure storage
      final secureStorage = SecureStorage();

      dataSource = FlashcardRemoteDataSourceImpl(
        apiClient: apiClient,
        secureStorage: secureStorage,
      );

      // Login
      print('🔐 Logging in...');
      try {
        // Try to register first (ignore if exists)
        try {
          await apiClient.dio.post(
            '/auth/register',
            data: {
              'email': 'test@example.com',
              'password': 'Test123456!',
              'name': 'Test User',
            },
          );
          print('✅ Registered new test user');
        } catch (e) {
          print('ℹ️  Test user already exists (skip registration)');
        }

        // Now login
        final response = await apiClient.dio.post(
          '/auth/login',
          data: {'email': 'test@example.com', 'password': 'Test123456!'},
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Extract token from response (handle both data wrapper and direct response)
          final responseData = response.data;
          if (responseData is Map) {
            if (responseData.containsKey('data') &&
                responseData['data'] is Map) {
              authToken = responseData['data']['accessToken'] as String;
            } else {
              authToken = responseData['accessToken'] as String;
            }
          }

          apiClient.setAuthToken(authToken!);
          print('✅ Logged in successfully');
          print('🔑 Token: ${authToken?.substring(0, 20)}...\n');
        }
      } catch (e) {
        print('❌ Login failed: $e');
        print('💡 Make sure backend is running!');
        rethrow;
      }
    });

    setUp(() async {
      print('\n' + '-' * 60);
      print('📦 Creating test deck...');

      try {
        // Create test deck
        final response = await apiClient.dio.post(
          '/flashcard-decks',
          data: {
            'name': 'API Test Deck ${DateTime.now().millisecondsSinceEpoch}',
            'description': 'Real API integration test',
            'isPublic': false,
          },
        );

        testDeckId = response.data['deckId'] as int;
        print('✅ Created deck: $testDeckId');

        // Add some test cards
        for (int i = 0; i < 5; i++) {
          await apiClient.dio.post(
            '/flashcard-cards',
            data: {
              'deckId': testDeckId,
              'character': '字$i',
              'meaning': 'Test meaning $i',
              'onyomi': 'オン$i',
              'kunyomi': 'くん$i',
              'examples': [
                {'word': '例$i', 'reading': 'れい$i', 'meaning': 'Example $i'},
              ],
            },
          );
        }
        print('✅ Added 5 test cards\n');
      } catch (e) {
        print('❌ Setup failed: $e');
        rethrow;
      }
    });

    tearDown(() async {
      if (testDeckId != null) {
        try {
          await apiClient.dio.delete('/flashcard-decks/$testDeckId');
          print('\n🗑️  Deleted test deck: $testDeckId');
        } catch (e) {
          print('⚠️  Could not delete deck: $e');
        }
      }
      print('-' * 60);
    });

    test(
      '🧪 TEST 1: Check active session when NONE exists (should return null)',
      () async {
        print('\n📝 Testing getActiveSession with no active session...');

        final result = await dataSource.getActiveSession(testDeckId!);

        print('📊 Result: $result');
        expect(
          result,
          isNull,
          reason: 'Should return null when no active session',
        );
        print('✅ PASS: Correctly returned null\n');
      },
    );

    test('🧪 TEST 2: Start session with ReviewType.all', () async {
      print('\n📝 Testing startSession with ReviewType.all...');

      final session = await dataSource.startSession(
        deckId: testDeckId!,
        maxNewCards: 5,
        maxReviewCards: 10,
        reviewType: ReviewType.all,
      );

      print('📊 Session created:');
      print('   Session ID: ${session.sessionId}');
      print('   Deck ID: ${session.deckId}');
      print('   Total cards: ${session.totalCards}');
      print('   New cards: ${session.newCards}');
      print('   Review cards: ${session.reviewCards}');

      expect(session.sessionId, isA<int>());
      expect(session.sessionId, isPositive);
      expect(session.deckId, equals(testDeckId));
      expect(session.totalCards, isPositive);

      print('✅ PASS: Session created successfully\n');

      // Cleanup
      await apiClient.dio.post(
        '/flashcard-sessions/${session.sessionId}/complete',
      );
    });

    test(
      '🧪 TEST 3: Check active session when ONE exists (should return session)',
      () async {
        print('\n📝 Testing getActiveSession with active session...');

        // First, create a session
        print('   Step 1: Creating session...');
        final session = await dataSource.startSession(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
        );
        print('   ✅ Session created: ${session.sessionId}');

        // Now check for active session
        print('   Step 2: Checking for active session...');
        final activeSession = await dataSource.getActiveSession(testDeckId!);

        print('📊 Active session found:');
        if (activeSession != null) {
          print('   Session ID: ${activeSession.sessionId}');
          print('   Deck ID: ${activeSession.deckId}');
          print('   Total cards: ${activeSession.totalCards}');
          print('   Cards reviewed: ${activeSession.cardsReviewed}');
          print('   Cards remaining: ${activeSession.cardsRemaining}');
          print('   Accuracy: ${activeSession.accuracy}%');
          print('   Started at: ${activeSession.startedAt}');
        }

        expect(activeSession, isNotNull);
        expect(activeSession!.sessionId, equals(session.sessionId));
        expect(activeSession.deckId, equals(testDeckId));
        expect(activeSession.totalCards, isA<int>());
        expect(activeSession.cardsReviewed, isA<int>());
        expect(activeSession.cardsRemaining, isA<int>());
        expect(activeSession.accuracy, isA<double>());
        expect(activeSession.startedAt, isA<DateTime>());

        print('✅ PASS: Active session returned correctly\n');

        // Cleanup
        await apiClient.dio.post(
          '/flashcard-sessions/${session.sessionId}/complete',
        );
      },
    );

    test('🧪 TEST 4: Type casting - Handle API returning doubles as integers', () async {
      print('\n📝 Testing type casting with real API response...');

      final session = await dataSource.startSession(
        deckId: testDeckId!,
        maxNewCards: 5,
        maxReviewCards: 10,
      );

      print('📊 Checking field types:');
      print(
        '   sessionId: ${session.sessionId} (${session.sessionId.runtimeType})',
      );
      print('   deckId: ${session.deckId} (${session.deckId.runtimeType})');
      print(
        '   totalCards: ${session.totalCards} (${session.totalCards.runtimeType})',
      );
      print(
        '   newCards: ${session.newCards} (${session.newCards.runtimeType})',
      );
      print(
        '   reviewCards: ${session.reviewCards} (${session.reviewCards.runtimeType})',
      );

      expect(session.sessionId, isA<int>());
      expect(session.deckId, isA<int>());
      expect(session.totalCards, isA<int>());
      expect(session.newCards, isA<int>());
      expect(session.reviewCards, isA<int>());

      // Check active session types
      final activeSession = await dataSource.getActiveSession(testDeckId!);
      expect(activeSession, isNotNull);

      print('\n📊 Active session field types:');
      print(
        '   sessionId: ${activeSession!.sessionId} (${activeSession.sessionId.runtimeType})',
      );
      print(
        '   totalCards: ${activeSession.totalCards} (${activeSession.totalCards.runtimeType})',
      );
      print(
        '   cardsReviewed: ${activeSession.cardsReviewed} (${activeSession.cardsReviewed.runtimeType})',
      );
      print(
        '   accuracy: ${activeSession.accuracy} (${activeSession.accuracy.runtimeType})',
      );

      expect(activeSession.sessionId, isA<int>());
      expect(activeSession.totalCards, isA<int>());
      expect(activeSession.cardsReviewed, isA<int>());
      expect(activeSession.accuracy, isA<double>());

      print('✅ PASS: All types correct\n');

      // Cleanup
      await apiClient.dio.post(
        '/flashcard-sessions/${session.sessionId}/complete',
      );
    });

    test('🧪 TEST 5: Start session with ReviewType.newOnly', () async {
      print('\n📝 Testing startSession with ReviewType.newOnly...');

      final session = await dataSource.startSession(
        deckId: testDeckId!,
        maxNewCards: 3,
        maxReviewCards: 10,
        reviewType: ReviewType.newOnly,
      );

      print('📊 Session with NEW_ONLY:');
      print('   Total cards: ${session.totalCards}');
      print('   New cards: ${session.newCards}');
      print('   Review cards: ${session.reviewCards}');

      expect(session.totalCards, equals(session.newCards));
      expect(session.reviewCards, equals(0));

      print('✅ PASS: NEW_ONLY filtering works\n');

      // Cleanup
      await apiClient.dio.post(
        '/flashcard-sessions/${session.sessionId}/complete',
      );
    });

    test('🧪 TEST 6: Handle null response gracefully', () async {
      print('\n📝 Testing null response handling...');

      // Check active session when none exists
      final result = await dataSource.getActiveSession(testDeckId!);

      print('📊 Result type: ${result.runtimeType}');
      print('📊 Result value: $result');

      expect(result, isNull);
      expect(() => result, returnsNormally);

      print('✅ PASS: Null handled without crash\n');
    });

    test(
      '🧪 TEST 7: Full flow - Start, check, complete, check again',
      () async {
        print('\n📝 Testing full session lifecycle...');

        // Step 1: No active session
        print('   Step 1: Check no active session...');
        var activeSession = await dataSource.getActiveSession(testDeckId!);
        expect(activeSession, isNull);
        print('   ✅ No active session');

        // Step 2: Start session
        print('   Step 2: Start session...');
        final session = await dataSource.startSession(
          deckId: testDeckId!,
          maxNewCards: 5,
          maxReviewCards: 10,
        );
        print('   ✅ Session started: ${session.sessionId}');

        // Step 3: Check active session exists
        print('   Step 3: Check active session exists...');
        activeSession = await dataSource.getActiveSession(testDeckId!);
        expect(activeSession, isNotNull);
        expect(activeSession!.sessionId, session.sessionId);
        print('   ✅ Active session found');

        // Step 4: Complete session
        print('   Step 4: Complete session...');
        await apiClient.dio.post(
          '/flashcard-sessions/${session.sessionId}/complete',
        );
        print('   ✅ Session completed');

        // Step 5: Check no active session again
        print('   Step 5: Check no active session after completion...');
        activeSession = await dataSource.getActiveSession(testDeckId!);
        expect(activeSession, isNull);
        print('   ✅ No active session after completion');

        print('✅ PASS: Full lifecycle works correctly\n');
      },
    );
  });
}
