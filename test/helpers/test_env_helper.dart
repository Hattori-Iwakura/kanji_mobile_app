import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Load environment variables for testing
///
/// Call this in setUpAll() of your test files:
/// ```dart
/// setUpAll(() async {
///   await loadEnvForTest();
///   await di.init();
/// });
/// ```
Future<void> loadEnvForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    // Try to load .env file
    await dotenv.load(fileName: '.env');
    print('✅ Loaded .env file successfully');
  } catch (e) {
    // If .env doesn't exist, use default values
    print('⚠️  Could not load .env file: $e');
    print('⚠️  Using default test values...');

    // Set default test environment variables
    dotenv.testLoad(
      fileInput: '''
API_BASE_URL=http://localhost:3000
API_TIMEOUT=30000
''',
    );
    print('✅ Loaded default test environment');
  }
}
