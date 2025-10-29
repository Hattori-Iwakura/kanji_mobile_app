import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/core/storage/secure_storage.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'mock_secure_storage.dart';
import 'mock_shared_preferences.dart';

/// Helper để setup môi trường test
class TestHelper {
  static bool _isInitialized = false;

  /// Initialize dependencies cho integration tests
  static Future<void> initializeDependencies() async {
    if (_isInitialized) {
      print('DEBUG: Already initialized, skipping...');
      return;
    }

    // IMPORTANT: DO NOT use TestWidgetsFlutterBinding for integration tests!
    // TestWidgetsFlutterBinding blocks all HTTP requests and returns 400.
    // Only use it for widget tests that need Flutter binding.
    // For integration tests that make real network calls, skip this line.

    // Load .env file
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      print('Warning: Could not load .env file: $e');
      // Set default values
      // Use localhost for tests running on Windows/desktop
      dotenv.testLoad(
        fileInput: '''
API_BASE_URL=http://localhost:3000/api
RAPIDAPI_KEY=ab84e2d5d7mshec320cda6671a01p122264jsnfa7b71b22317
CONNECTION_TIMEOUT=30000
RECEIVE_TIMEOUT=30000
''',
      );
    }

    // Reset GetIt to clean state
    await di.sl.reset();
    print('DEBUG: GetIt reset complete');

    // Initialize dependency injection with mock SharedPreferences
    await di.initializeDependencies(
      mockSharedPreferences: MockSharedPreferences(),
    );
    print(
      'DEBUG: Dependencies initialized, ApiClient registered? ${di.sl.isRegistered<ApiClient>()}',
    );

    // Replace real SecureStorage with MockSecureStorage for tests
    // flutter_secure_storage doesn't work in test environment
    if (di.sl.isRegistered<SecureStorage>()) {
      await di.sl.unregister<SecureStorage>();
    }
    di.sl.registerLazySingleton<SecureStorage>(() => MockSecureStorage());

    _isInitialized = true;
    print('DEBUG: Initialization complete');
  }

  /// Reset dependencies (for cleaning between tests)
  static Future<void> resetDependencies() async {
    _isInitialized = false;
  }

  /// Print test section header
  static void printSection(String title) {
    print('\n${'=' * 60}');
    print('  $title');
    print('=' * 60);
  }

  /// Print test step
  static void printStep(String step) {
    print('→ $step');
  }

  /// Print success message
  static void printSuccess(String message) {
    print('✓ $message');
  }

  /// Print error message
  static void printError(String message) {
    print('✗ $message');
  }
}
