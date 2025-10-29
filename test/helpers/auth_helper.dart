import 'package:dio/dio.dart';
import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/core/storage/secure_storage.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;

class AuthHelper {
  static String? _cachedToken;
  static DateTime? _tokenExpiry;

  /// Login and get JWT token for testing
  /// Returns the token or throws an error
  static Future<String> loginForTesting({
    String account =
        'test@example.com', // Use account field (can be email or username)
    String password = 'Test123456',
  }) async {
    // Check if cached token is still valid
    if (_cachedToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!)) {
        return _cachedToken!;
      }
    }

    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'account': account,
          'password': password,
        }, // Changed from 'email' to 'account'
      );

      final token = response.data['data']['accessToken'] as String;

      // Cache token for 1 hour (assume token expires in 24h, keep cache shorter)
      _cachedToken = token;
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));

      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(
          'Authentication failed. Please ensure test user exists: $account',
        );
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Register a test user (if not exists)
  static Future<void> registerTestUser({
    String email = 'test@example.com',
    String password = 'Test123456',
    String username = 'testuser',
  }) async {
    try {
      final apiClient = di.sl<ApiClient>();
      await apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': username, // Note: backend uses 'name' not 'username'
        },
      );
    } on DioException catch (e) {
      // Ignore if user already exists (409 Conflict or 400 Bad Request)
      if (e.response?.statusCode != 409 && e.response?.statusCode != 400) {
        throw Exception('Registration failed: ${e.message}');
      }
      // User already exists, that's fine
      print('DEBUG: User already exists or registration skipped');
    }
  }

  /// Setup authentication for tests
  /// Registers test user if needed, logs in, and sets token
  static Future<void> setupAuth() async {
    // Debug: Check if ApiClient is registered
    print('DEBUG: ApiClient registered? ${di.sl.isRegistered<ApiClient>()}');

    try {
      // Try to register (will fail silently if exists)
      print('DEBUG: Attempting to register test user...');
      await registerTestUser();
      print('DEBUG: Registration attempt completed');

      // Login and get token
      print('DEBUG: Attempting to login...');
      final token = await loginForTesting();
      print(
        'DEBUG: Login successful, token received: ${token.substring(0, 20)}...',
      );

      // IMPORTANT: Set token in SecureStorage (datasources read from here)
      final secureStorage = di.sl<SecureStorage>();
      await secureStorage.saveToken(token);
      print('DEBUG: Token saved to SecureStorage');

      // Also set in ApiClient for direct API calls
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);
      print('DEBUG: Token set in ApiClient');

      print('DEBUG: Authentication setup complete');
    } catch (e, stackTrace) {
      print('DEBUG ERROR in setupAuth: $e');
      print('DEBUG STACK: $stackTrace');
      rethrow;
    }
  }

  /// Clear authentication
  static void clearAuth() {
    _cachedToken = null;
    _tokenExpiry = null;
    try {
      if (di.sl.isRegistered<ApiClient>()) {
        final apiClient = di.sl<ApiClient>();
        apiClient.clearAuthToken();
      }
    } catch (e) {
      // Ignore errors during cleanup
    }
  }
}
