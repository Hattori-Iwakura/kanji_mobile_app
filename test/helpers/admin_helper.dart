import 'package:kanji_mobile_app/core/network/api_client.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'auth_helper.dart';

/// Helper for admin-specific testing operations
class AdminHelper {
  /// Login as admin user and return token
  static Future<String> loginAsAdmin() async {
    return await AuthHelper.loginForTesting(
      account: 'admin@gmail.com',
      password: 'Admin@12345',
    );
  }

  /// Setup admin authentication
  /// - Logs in as admin user
  /// - Sets token in ApiClient
  static Future<void> setupAdminAuth() async {
    try {
      print('DEBUG: Setting up admin authentication...');

      final token = await loginAsAdmin();
      print('DEBUG: Admin login successful');

      // Set token in ApiClient
      final apiClient = di.sl<ApiClient>();
      apiClient.setAuthToken(token);
      print('DEBUG: Admin token set in ApiClient');

      print('DEBUG: Admin authentication setup complete');
    } catch (e, stackTrace) {
      print('DEBUG ERROR in setupAdminAuth: $e');
      print('DEBUG STACK: $stackTrace');
      rethrow;
    }
  }

  /// Verify admin access
  /// Returns true if admin endpoints are accessible
  static Future<bool> verifyAdminAccess() async {
    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.dio.get('/admin/system/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Clear admin authentication
  static void clearAdminAuth() {
    AuthHelper.clearAuth();
  }
}
