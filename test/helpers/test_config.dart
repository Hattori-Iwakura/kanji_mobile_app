/// Test configuration cho integration tests
class TestConfig {
  // API URL cho testing (đảm bảo backend đang chạy)
  static const String apiBaseUrl = 'http://localhost:3000/api';

  // Test user credentials
  static const String testEmail = 'nhatnsm1225@gmail.com';
  static const String testPassword = 'Test@123456';
  static const String testName = 'Test User 2FA';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration longTimeout = Duration(minutes: 2);

  // 2FA Testing
  static const String twoFactorTestEmail = 'nhatnsm1225@gmail.com';
}
