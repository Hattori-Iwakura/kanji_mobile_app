import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:mockito/mockito.dart';

class TestHelper {
  // Test user credentials
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123456!';

  // Base URL - adjust to your backend URL
  static const String baseUrl = 'http://localhost:3000/api';

  // ANSI color codes for terminal output
  static const String _reset = '\x1B[0m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _cyan = '\x1B[36m';
  static const String _bold = '\x1B[1m';

  /// Print a header message
  static void printHeader(String message) {
    print(
      '\n$_bold$_cyan═══════════════════════════════════════════════════════$_reset',
    );
    print('$_bold$_cyan  $message$_reset');
    print(
      '$_bold$_cyan═══════════════════════════════════════════════════════$_reset\n',
    );
  }

  /// Print a test name
  static void printTest(String message) {
    print('$_bold$_blue▶ TEST: $message$_reset');
  }

  /// Print success message
  static void printSuccess(String message) {
    print('$_green✓ $message$_reset');
  }

  /// Print error message
  static void printError(String message) {
    print('$_red✗ ERROR: $message$_reset');
  }

  /// Print warning message
  static void printWarning(String message) {
    print('$_yellow⚠ WARNING: $message$_reset');
  }

  /// Print info message
  static void printInfo(String message) {
    print('$_cyan  ℹ $message$_reset');
  }

  /// Create API client for testing
  static ApiClient createApiClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Silent logging or use printInfo for debugging
          // printInfo(obj.toString());
        },
      ),
    );

    return ApiClient(dio: dio);
  }

  /// Create mock secure storage
  static FlutterSecureStorage createMockSecureStorage() {
    return const FlutterSecureStorage();
  }

  /// Login and return auth token
  static Future<String> loginTestUser(ApiClient apiClient) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': testEmail, 'password': testPassword},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map && data.containsKey('accessToken')) {
          final token = data['accessToken'] as String;

          // Set token in API client
          apiClient.dio.options.headers['Authorization'] = 'Bearer $token';

          return token;
        }
      }
      throw Exception('Login failed: Invalid response format');
    } catch (e) {
      printError('Login failed: $e');
      rethrow;
    }
  }

  /// Register a test user if not exists
  static Future<void> registerTestUser(ApiClient apiClient) async {
    try {
      await apiClient.dio.post(
        '/auth/register',
        data: {
          'email': testEmail,
          'password': testPassword,
          'username': 'testuser',
        },
      );
      printSuccess('Test user registered');
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 409 || e.response?.statusCode == 400) {
          printInfo('Test user already exists');
          return;
        }
      }
      printWarning('Could not register test user: $e');
    }
  }

  /// Create a test deck with some cards
  static Future<Map<String, dynamic>> createTestDeck(
    ApiClient apiClient,
    String token, {
    String? name,
    int cardCount = 5,
  }) async {
    try {
      // Set auth header
      apiClient.dio.options.headers['Authorization'] = 'Bearer $token';

      // Create deck
      final deckResponse = await apiClient.dio.post(
        '/flashcard-decks',
        data: {
          'name': name ?? 'Test Deck ${DateTime.now().millisecondsSinceEpoch}',
          'description': 'Integration test deck',
          'isPublic': false,
        },
      );

      if (deckResponse.statusCode != 200 && deckResponse.statusCode != 201) {
        throw Exception('Failed to create deck');
      }

      final deckData = deckResponse.data;
      final deckId = deckData['deckId'] as int;

      // Add some cards
      final List<int> cardIds = [];
      for (int i = 0; i < cardCount; i++) {
        final cardResponse = await apiClient.dio.post(
          '/flashcard-cards',
          data: {
            'deckId': deckId,
            'character': '字$i',
            'meaning': 'Meaning $i',
            'onyomi': 'オン$i',
            'kunyomi': 'くん$i',
            'examples': [
              {'word': '例$i', 'reading': 'れい$i', 'meaning': 'Example $i'},
            ],
          },
        );

        if (cardResponse.statusCode == 200 || cardResponse.statusCode == 201) {
          final cardData = cardResponse.data;
          cardIds.add(cardData['cardId'] as int);
        }
      }

      printSuccess('Created deck $deckId with ${cardIds.length} cards');

      return {'deckId': deckId, 'cardIds': cardIds};
    } catch (e) {
      printError('Failed to create test deck: $e');
      rethrow;
    }
  }

  /// Delete a deck
  static Future<void> deleteDeck(
    ApiClient apiClient,
    String token,
    int deckId,
  ) async {
    try {
      apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
      await apiClient.dio.delete('/flashcard-decks/$deckId');
      printSuccess('Deleted deck $deckId');
    } catch (e) {
      printWarning('Could not delete deck: $e');
    }
  }

  /// Review a card to make it "due" for testing
  static Future<void> makeCardDue(
    ApiClient apiClient,
    String token,
    int sessionId,
    int cardId,
  ) async {
    try {
      apiClient.dio.options.headers['Authorization'] = 'Bearer $token';

      // Review with quality 3 (should schedule for review)
      await apiClient.dio.post(
        '/flashcard-sessions/$sessionId/review',
        data: {'cardId': cardId, 'quality': 3, 'timeSpent': 5.0},
      );

      printInfo('Card $cardId reviewed and scheduled');
    } catch (e) {
      printWarning('Could not review card: $e');
    }
  }

  /// Wait for a condition with timeout
  static Future<void> waitFor(
    Future<bool> Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await condition()) {
        return;
      }
      await Future.delayed(pollInterval);
    }

    throw Exception('Timeout waiting for condition');
  }

  /// Compare two objects and print differences
  static void compareObjects(dynamic expected, dynamic actual, String name) {
    if (expected.runtimeType != actual.runtimeType) {
      printError('Type mismatch for $name:');
      printInfo('  Expected type: ${expected.runtimeType}');
      printInfo('  Actual type: ${actual.runtimeType}');
      return;
    }

    if (expected != actual) {
      printError('Value mismatch for $name:');
      printInfo('  Expected: $expected');
      printInfo('  Actual: $actual');
    } else {
      printSuccess('$name matches: $actual');
    }
  }

  /// Assert type and print result
  static void assertType<T>(dynamic value, String name) {
    if (value is T) {
      printSuccess('$name has correct type: ${T.toString()}');
    } else {
      printError('$name has wrong type:');
      printInfo('  Expected: ${T.toString()}');
      printInfo('  Actual: ${value.runtimeType}');
    }
  }

  /// Print object details for debugging
  static void printObject(dynamic obj, String name) {
    printInfo('$name details:');
    if (obj == null) {
      printInfo('  null');
      return;
    }

    if (obj is Map) {
      obj.forEach((key, value) {
        printInfo('  $key: $value (${value.runtimeType})');
      });
    } else {
      printInfo('  Type: ${obj.runtimeType}');
      printInfo('  Value: $obj');
    }
  }
}
