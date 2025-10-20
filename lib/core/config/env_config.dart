import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
/// Provides access to environment variables loaded from .env file
class EnvConfig {
  // API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // AI Model Configuration
  static String get aiModelUrl =>
      dotenv.env['AI_MODEL_URL'] ?? 'http://localhost:8000';

  // Feature Flags
  static bool get isDebugMode =>
      dotenv.env['ENABLE_DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get isAnalyticsEnabled =>
      dotenv.env['ENABLE_ANALYTICS']?.toLowerCase() == 'true';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'Kanji Learning App';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  /// Check if environment is properly loaded
  static bool get isLoaded => dotenv.isInitialized;

  /// Get raw environment variable
  static String? getEnv(String key) => dotenv.env[key];

  /// Print all configuration (for debugging)
  static void printConfig() {
    if (isDebugMode) {
      print('=== Environment Configuration ===');
      print('API Base URL: $apiBaseUrl');
      print('API Timeout: $apiTimeout');
      print('AI Model URL: $aiModelUrl');
      print('Debug Mode: $isDebugMode');
      print('Analytics: $isAnalyticsEnabled');
      print('App Name: $appName');
      print('App Version: $appVersion');
      print('================================');
    }
  }
}
