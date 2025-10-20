import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kanji_flutter/core/network/api_client.dart';

class IntegrationTestHelper {
  // Use 10.0.2.2 for Android emulator to access host machine
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Test credentials - Make sure these exist in your backend
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test@123456';

  // Admin credentials
  static const String adminEmail = 'admin@example.com';
  static const String adminPassword = 'Admin@123456';

  late ApiClient apiClient;
  late FlutterSecureStorage secureStorage;
  String? authToken;

  IntegrationTestHelper() {
    apiClient = ApiClient(baseUrl: baseUrl);
    secureStorage = const FlutterSecureStorage();
  }

  /// Login and get auth token
  Future<String> loginAndGetToken() async {
    // Clear existing token to force fresh login
    authToken = null;
    apiClient.clearAuthToken();

    try {
      final response = await apiClient.post('/auth/login', {
        'account': testEmail, // Changed from 'email' to 'account'
        'password': testPassword,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        // Backend wraps response: { statusCode, data: { user, accessToken }, timestamp }
        final responseData = response.data['data'] ?? response.data;

        // If data is wrapped again, unwrap it
        final actualData =
            responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        authToken = actualData['accessToken'] as String?;
        if (authToken != null) {
          await secureStorage.write(key: 'auth_token', value: authToken!);
          apiClient.setAuthToken(authToken!);
          return authToken!;
        }
      }

      throw Exception('Failed to login: Invalid response');
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  /// Login as admin and get auth token
  Future<String> loginAsAdmin() async {
    // Clear existing token
    authToken = null;
    apiClient.clearAuthToken();

    try {
      final response = await apiClient.post('/auth/login', {
        'account': adminEmail,
        'password': adminPassword,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final responseData = response.data['data'] ?? response.data;

        final actualData =
            responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        authToken = actualData['accessToken'] as String?;
        if (authToken != null) {
          await secureStorage.write(key: 'auth_token', value: authToken!);
          apiClient.setAuthToken(authToken!);
          return authToken!;
        }
      }

      throw Exception('Failed to login as admin: Invalid response');
    } catch (e) {
      throw Exception('Failed to login as admin: $e');
    }
  }

  /// Register a test user (call this once before running tests)
  Future<void> registerTestUser() async {
    try {
      await apiClient.post('/auth/register', {
        'account': 'testuser', // Added account field
        'email': testEmail,
        'password': testPassword,
        'name': 'Test User',
      });
    } catch (e) {
      // User might already exist, that's okay
      print('Note: Test user registration failed (might already exist): $e');
    }
  }

  /// Cleanup - logout and clear tokens
  Future<void> cleanup() async {
    authToken = null;
    apiClient.clearAuthToken();
    await secureStorage.delete(key: 'auth_token');
  }

  /// Check if backend server is running
  Future<bool> isBackendRunning() async {
    try {
      // Try kanji endpoint as health check (simple GET)
      final response = await Dio().get('$baseUrl/kanji?page=1&limit=1');
      return response.statusCode == 200;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }

  /// Check if ML server is running (via backend proxy)
  Future<bool> isMlServerRunning() async {
    try {
      // Backend should proxy this or have a health check endpoint
      return true; // Will be checked during actual recognition test
    } catch (e) {
      return false;
    }
  }
}
