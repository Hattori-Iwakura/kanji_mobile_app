import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kanji_mobile_v1/core/di/injection.dart';
import 'package:kanji_mobile_v1/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Integration Tests with Backend', () {
    late AuthRepository authRepository;

    // Test credentials
    final testAccount = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
    const testEmail = 'test@example.com';
    const testPassword = 'Test@123456';

    setUpAll(() async {
      // Load environment
      await dotenv.load(fileName: '.env');

      // Setup dependencies
      SharedPreferences.setMockInitialValues({});

      // Initialize DI
      await setupDependencyInjection();

      // Setup auth repository
      authRepository = getIt<AuthRepository>();
    });

    tearDownAll(() async {
      // Cleanup: logout and clear data
      try {
        await authRepository.logout();
      } catch (e) {
        // Ignore errors during cleanup
      }
    });

    test('Register new user successfully', () async {
      final result = await authRepository.register(
        account: testAccount,
        email: testEmail,
        password: testPassword,
      );

      result.fold(
        (failure) =>
            fail('Registration should succeed but got: ${failure.message}'),
        (authResult) {
          expect(authResult.user.account, equals(testAccount));
          expect(authResult.user.email, equals(testEmail));
          expect(authResult.accessToken, isNotEmpty);
          expect(authResult.refreshToken, isNotEmpty);
          expect(authResult.sessionId, isNotEmpty);
        },
      );
    });

    test('Login with valid credentials', () async {
      final result = await authRepository.login(
        account: testAccount,
        password: testPassword,
      );

      result.fold(
        (failure) => fail('Login should succeed but got: ${failure.message}'),
        (authResult) {
          expect(authResult.user.account, equals(testAccount));
          expect(authResult.accessToken, isNotEmpty);
          expect(authResult.refreshToken, isNotEmpty);
        },
      );
    });

    test('Login with invalid credentials fails', () async {
      final result = await authRepository.login(
        account: testAccount,
        password: 'WrongPassword123',
      );

      result.fold((failure) {
        expect(failure.message, contains('Invalid'));
      }, (authResult) => fail('Login should fail with invalid credentials'));
    });

    test('Get profile after login', () async {
      // Login first
      await authRepository.login(account: testAccount, password: testPassword);

      // Get profile
      final result = await authRepository.getProfile();

      result.fold(
        (failure) =>
            fail('Get profile should succeed but got: ${failure.message}'),
        (user) {
          expect(user.account, equals(testAccount));
          expect(user.email, equals(testEmail));
        },
      );
    });

    test('Logout successfully', () async {
      // Login first
      await authRepository.login(account: testAccount, password: testPassword);

      // Logout
      final result = await authRepository.logout();

      result.fold(
        (failure) => fail('Logout should succeed but got: ${failure.message}'),
        (_) {
          // Logout successful
          expect(true, isTrue);
        },
      );
    });

    test('Register with duplicate account fails', () async {
      final result = await authRepository.register(
        account: testAccount, // Use same account
        email: 'different@example.com',
        password: testPassword,
      );

      result.fold(
        (failure) {
          expect(failure.message, contains('already exists'));
        },
        (authResult) => fail('Registration should fail with duplicate account'),
      );
    });

    test('Forgot password sends reset link', () async {
      final result = await authRepository.forgotPassword(email: testEmail);

      result.fold(
        (failure) =>
            fail('Forgot password should succeed but got: ${failure.message}'),
        (_) {
          // Success - reset link sent (check email in backend)
          expect(true, isTrue);
        },
      );
    });

    test('Change password with valid old password', () async {
      // Login first
      await authRepository.login(account: testAccount, password: testPassword);

      const newPassword = 'NewTest@123456';

      final result = await authRepository.changePassword(
        oldPassword: testPassword,
        newPassword: newPassword,
      );

      result.fold(
        (failure) =>
            fail('Change password should succeed but got: ${failure.message}'),
        (_) {
          // Password changed successfully
          // Try login with new password
          authRepository
              .login(account: testAccount, password: newPassword)
              .then((loginResult) {
                loginResult.fold(
                  (failure) => fail('Login with new password should succeed'),
                  (authResult) => expect(authResult.accessToken, isNotEmpty),
                );
              });
        },
      );
    });

    test('Refresh token works correctly', () async {
      // Login first
      final loginResult = await authRepository.login(
        account: testAccount,
        password: testPassword,
      );

      String? refreshToken;
      loginResult.fold((failure) => fail('Login should succeed'), (authResult) {
        refreshToken = authResult.refreshToken;
      });

      // Wait a bit
      await Future.delayed(const Duration(seconds: 1));

      // Refresh token
      final refreshResult = await authRepository.refreshToken(
        refreshToken: refreshToken!,
      );

      refreshResult.fold(
        (failure) =>
            fail('Refresh token should succeed but got: ${failure.message}'),
        (newAuthResult) {
          expect(newAuthResult.accessToken, isNotEmpty);
          expect(newAuthResult.refreshToken, isNotEmpty);
          expect(newAuthResult.accessToken, isNot(equals(refreshToken)));
        },
      );
    });
  });
}
