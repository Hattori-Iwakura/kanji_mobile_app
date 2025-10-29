import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/features/auth/domain/usecases/register.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/login.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/logout.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/get_profile.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/update_profile.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/forgot_password.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/reset_password.dart';
import '../helpers/test_helper.dart';
import '../helpers/test_config.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING AUTH COMPLETE TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');
  });

  group('1. Registration Tests -', () {
    late Register register;
    late Login login;
    late Logout logout;

    setUp(() {
      register = di.sl<Register>();
      login = di.sl<Login>();
      logout = di.sl<Logout>();
    });

    test('1.1. Register with valid data', () async {
      TestHelper.printSection('TEST 1.1: REGISTER WITH VALID DATA');

      final testEmail =
          'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      TestHelper.printStep('Email: $testEmail');

      final result = await register(
        testEmail,
        TestConfig.testPassword,
        'Test User Valid',
      );

      result.fold(
        (failure) {
          TestHelper.printError('Registration failed: ${failure.message}');
          fail('Registration should succeed with valid data');
        },
        (user) {
          TestHelper.printSuccess('Registration successful');
          TestHelper.printSuccess('User ID: ${user.id}');
          TestHelper.printSuccess('Email: ${user.email}');
          TestHelper.printSuccess('Name: ${user.name}');

          expect(user.email, testEmail);
          expect(user.name, 'Test User Valid');
          expect(user.isTwoFactorEnabled, false);
        },
      );

      // Cleanup
      await login(testEmail, TestConfig.testPassword);
      await logout();
    });

    test('1.2. Register with duplicate email', () async {
      TestHelper.printSection('TEST 1.2: REGISTER WITH DUPLICATE EMAIL');

      // Register first time
      final testEmail =
          'duplicate_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(testEmail, TestConfig.testPassword, 'First User');

      TestHelper.printStep(
        'Attempting to register duplicate email: $testEmail',
      );

      // Try to register again with same email
      final result = await register(
        testEmail,
        TestConfig.testPassword,
        'Second User',
      );

      result.fold(
        (failure) {
          TestHelper.printSuccess(
            'Duplicate registration blocked (as expected)',
          );
          TestHelper.printSuccess('Error: ${failure.message}');
          expect(
            failure.message.toLowerCase(),
            anyOf(
              contains('already'),
              contains('exist'),
              contains('duplicate'),
            ),
          );
        },
        (user) {
          TestHelper.printError('Should not allow duplicate email');
          fail('Duplicate email registration should fail');
        },
      );
    });

    test('1.3. Register with invalid email format', () async {
      TestHelper.printSection('TEST 1.3: REGISTER WITH INVALID EMAIL');

      TestHelper.printStep('Attempting with invalid email: invalid-email');

      final result = await register(
        'invalid-email',
        TestConfig.testPassword,
        'Test User',
      );

      result.fold(
        (failure) {
          TestHelper.printSuccess('Invalid email rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (user) {
          TestHelper.printError('Should not accept invalid email format');
          fail('Invalid email should be rejected');
        },
      );
    });

    test('1.4. Register with weak password', () async {
      TestHelper.printSection('TEST 1.4: REGISTER WITH WEAK PASSWORD');

      final testEmail =
          'weak_${DateTime.now().millisecondsSinceEpoch}@example.com';
      TestHelper.printStep('Attempting with weak password: 123');

      final result = await register(testEmail, '123', 'Test User');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Weak password rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (user) {
          TestHelper.printError('Should not accept weak password');
          fail('Weak password should be rejected');
        },
      );
    });

    test('1.5. Register with missing name', () async {
      TestHelper.printSection('TEST 1.5: REGISTER WITH EMPTY NAME');

      final testEmail =
          'noname_${DateTime.now().millisecondsSinceEpoch}@example.com';
      TestHelper.printStep('Attempting with empty name');

      final result = await register(testEmail, TestConfig.testPassword, '');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Empty name rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (user) {
          TestHelper.printError('Should not accept empty name');
          fail('Empty name should be rejected');
        },
      );
    });
  });

  group('2. Login Tests -', () {
    late Register register;
    late Login login;

    String? testEmail;
    String? testPassword;

    setUpAll(() async {
      register = di.sl<Register>();
      login = di.sl<Login>();

      // Create a test user for login tests
      testEmail =
          'login_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      testPassword = TestConfig.testPassword;

      final result = await register(
        testEmail!,
        testPassword!,
        'Login Test User',
      );
      result.fold(
        (failure) => fail('Setup failed: ${failure.message}'),
        (_) => TestHelper.printSuccess('Test user created for login tests'),
      );
    });

    setUp(() {
      login = di.sl<Login>();
    });

    test('2.1. Login with valid credentials', () async {
      TestHelper.printSection('TEST 2.1: LOGIN WITH VALID CREDENTIALS');

      TestHelper.printStep('Email: $testEmail');

      final result = await login(testEmail!, testPassword!);

      result.fold(
        (failure) {
          TestHelper.printError('Login failed: ${failure.message}');
          fail('Login should succeed with valid credentials');
        },
        (user) {
          TestHelper.printSuccess('Login successful');
          TestHelper.printSuccess('User: ${user.email}');
          TestHelper.printSuccess('Role: ${user.role}');

          expect(user.email, testEmail);
        },
      );
    });

    test('2.2. Login with wrong password', () async {
      TestHelper.printSection('TEST 2.2: LOGIN WITH WRONG PASSWORD');

      TestHelper.printStep('Attempting with wrong password');

      final result = await login(testEmail!, 'WrongPassword123!@#');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Wrong password rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
          expect(
            failure.message.toLowerCase(),
            anyOf(
              contains('invalid'),
              contains('incorrect'),
              contains('wrong'),
            ),
          );
        },
        (user) {
          TestHelper.printError('Should not login with wrong password');
          fail('Wrong password should be rejected');
        },
      );
    });

    test('2.3. Login with non-existent email', () async {
      TestHelper.printSection('TEST 2.3: LOGIN WITH NON-EXISTENT EMAIL');

      final fakeEmail =
          'nonexistent_${DateTime.now().millisecondsSinceEpoch}@example.com';
      TestHelper.printStep('Email: $fakeEmail');

      final result = await login(fakeEmail, testPassword!);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Non-existent email rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (user) {
          TestHelper.printError('Should not login with non-existent email');
          fail('Non-existent email should be rejected');
        },
      );
    });

    test('2.4. Login with empty password', () async {
      TestHelper.printSection('TEST 2.4: LOGIN WITH EMPTY PASSWORD');

      TestHelper.printStep('Attempting with empty password');

      final result = await login(testEmail!, '');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Empty password rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (user) {
          TestHelper.printError('Should not login with empty password');
          fail('Empty password should be rejected');
        },
      );
    });

    test('2.5. Multiple consecutive logins', () async {
      TestHelper.printSection('TEST 2.5: MULTIPLE CONSECUTIVE LOGINS');

      TestHelper.printStep('Performing 3 consecutive logins');

      for (int i = 1; i <= 3; i++) {
        TestHelper.printStep('Login attempt $i');

        final result = await login(testEmail!, testPassword!);

        result.fold((failure) => fail('Login $i failed: ${failure.message}'), (
          user,
        ) {
          TestHelper.printSuccess('Login $i successful');
          expect(user.email, testEmail);
        });
      }

      TestHelper.printSuccess('All 3 logins successful');
    });
  });

  group('3. Profile Tests -', () {
    late Register register;
    late Login login;
    late GetProfile getProfile;
    late UpdateProfile updateProfile;

    String? testEmail;

    setUpAll(() async {
      register = di.sl<Register>();
      login = di.sl<Login>();
      getProfile = di.sl<GetProfile>();
      updateProfile = di.sl<UpdateProfile>();

      // Create and login test user
      testEmail =
          'profile_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(testEmail!, TestConfig.testPassword, 'Profile Test User');
      await login(testEmail!, TestConfig.testPassword);
    });

    test('3.1. Get profile when authenticated', () async {
      TestHelper.printSection('TEST 3.1: GET PROFILE (AUTHENTICATED)');

      final result = await getProfile();

      result.fold(
        (failure) {
          TestHelper.printError('Get profile failed: ${failure.message}');
          fail('Should be able to get profile when authenticated');
        },
        (user) {
          TestHelper.printSuccess('Profile retrieved successfully');
          TestHelper.printSuccess('Email: ${user.email}');
          TestHelper.printSuccess('Name: ${user.name}');
          TestHelper.printSuccess('Role: ${user.role}');
          TestHelper.printSuccess('2FA Status: ${user.isTwoFactorEnabled}');

          expect(user.email, testEmail);
        },
      );
    });

    test('3.2. Update profile name', () async {
      TestHelper.printSection('TEST 3.2: UPDATE PROFILE NAME');

      final newName = 'Updated Name ${DateTime.now().millisecondsSinceEpoch}';
      TestHelper.printStep('Updating name to: $newName');

      final result = await updateProfile(name: newName);

      result.fold(
        (failure) {
          TestHelper.printError('Update failed: ${failure.message}');
          fail('Should be able to update profile name');
        },
        (user) {
          TestHelper.printSuccess('Profile updated successfully');
          TestHelper.printSuccess('New name: ${user.name}');

          expect(user.name, newName);
        },
      );
    });

    test('3.3. Update profile with empty name', () async {
      TestHelper.printSection('TEST 3.3: UPDATE PROFILE WITH EMPTY NAME');

      TestHelper.printStep('Attempting to update with empty name');

      final result = await updateProfile(name: '');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Empty name rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (user) {
          TestHelper.printError('Should not accept empty name');
          fail('Empty name should be rejected');
        },
      );
    });

    test('3.4. Get profile after logout', () async {
      TestHelper.printSection('TEST 3.4: GET PROFILE AFTER LOGOUT');

      final logout = di.sl<Logout>();
      TestHelper.printStep('Logging out...');
      await logout();

      TestHelper.printStep('Attempting to get profile...');
      final result = await getProfile();

      result.fold(
        (failure) {
          TestHelper.printSuccess('Profile access denied (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
          expect(
            failure.message.toLowerCase(),
            anyOf(
              contains('unauthorized'),
              contains('expired'),
              contains('invalid'),
            ),
          );
        },
        (user) {
          TestHelper.printError('Should not access profile after logout');
          fail('Profile should not be accessible after logout');
        },
      );

      // Re-login for other tests
      final login = di.sl<Login>();
      await login(testEmail!, TestConfig.testPassword);
    });
  });

  group('4. Password Management Tests -', () {
    late Register register;
    late ForgotPassword forgotPassword;
    late ResetPassword resetPassword;

    String? testEmail;

    setUpAll(() async {
      register = di.sl<Register>();
      forgotPassword = di.sl<ForgotPassword>();
      resetPassword = di.sl<ResetPassword>();

      // Create test user
      testEmail =
          'password_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(testEmail!, TestConfig.testPassword, 'Password Test User');
    });

    test('4.1. Request password reset with valid email', () async {
      TestHelper.printSection('TEST 4.1: FORGOT PASSWORD - VALID EMAIL');

      TestHelper.printStep('Email: $testEmail');
      TestHelper.printStep('Requesting password reset...');

      final result = await forgotPassword(testEmail!);

      result.fold(
        (failure) {
          TestHelper.printError('Forgot password failed: ${failure.message}');
          fail('Should be able to request password reset');
        },
        (_) {
          TestHelper.printSuccess('Password reset email sent');
          TestHelper.printSuccess('Check email: $testEmail');
        },
      );
    });

    test('4.2. Request password reset with non-existent email', () async {
      TestHelper.printSection('TEST 4.2: FORGOT PASSWORD - NON-EXISTENT EMAIL');

      final fakeEmail =
          'nonexistent_${DateTime.now().millisecondsSinceEpoch}@example.com';
      TestHelper.printStep('Email: $fakeEmail');

      final result = await forgotPassword(fakeEmail);

      result.fold(
        (failure) {
          TestHelper.printSuccess('Request handled (email not found)');
          TestHelper.printSuccess('Message: ${failure.message}');
        },
        (_) {
          // Some APIs return success even for non-existent emails (security)
          TestHelper.printSuccess('Request handled (security - no indication)');
        },
      );
    });

    test('4.3. Request password reset with invalid email', () async {
      TestHelper.printSection('TEST 4.3: FORGOT PASSWORD - INVALID EMAIL');

      TestHelper.printStep('Attempting with invalid email: not-an-email');

      final result = await forgotPassword('not-an-email');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Invalid email rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (_) {
          TestHelper.printError('Should validate email format');
          fail('Invalid email should be rejected');
        },
      );
    });

    test('4.4. Reset password with invalid token', () async {
      TestHelper.printSection('TEST 4.4: RESET PASSWORD - INVALID TOKEN');

      TestHelper.printStep('Attempting with fake token');

      final result = await resetPassword('fake-token-123', 'NewPassword123!@#');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Invalid token rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
          expect(
            failure.message.toLowerCase(),
            anyOf(contains('invalid'), contains('expired'), contains('token')),
          );
        },
        (_) {
          TestHelper.printError('Should not accept invalid token');
          fail('Invalid token should be rejected');
        },
      );
    });

    test('4.5. Reset password with weak password', () async {
      TestHelper.printSection('TEST 4.5: RESET PASSWORD - WEAK PASSWORD');

      TestHelper.printStep('Attempting with weak password: 123');

      final result = await resetPassword('any-token', '123');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Weak password rejected (as expected)');
          TestHelper.printSuccess('Error: ${failure.message}');
        },
        (_) {
          TestHelper.printError('Should not accept weak password');
          fail('Weak password should be rejected');
        },
      );
    });

    test('4.6. Multiple forgot password requests', () async {
      TestHelper.printSection('TEST 4.6: MULTIPLE FORGOT PASSWORD REQUESTS');

      TestHelper.printStep('Sending 3 consecutive requests');

      for (int i = 1; i <= 3; i++) {
        TestHelper.printStep('Request $i');

        final result = await forgotPassword(testEmail!);

        result.fold(
          (failure) =>
              TestHelper.printError('Request $i failed: ${failure.message}'),
          (_) => TestHelper.printSuccess('Request $i sent'),
        );

        // Wait a bit between requests
        await Future.delayed(const Duration(milliseconds: 500));
      }

      TestHelper.printSuccess('All requests completed');
    });
  });

  group('5. Logout Tests -', () {
    late Register register;
    late Login login;
    late Logout logout;
    late GetProfile getProfile;

    String? testEmail;

    setUpAll(() async {
      register = di.sl<Register>();
      login = di.sl<Login>();
      getProfile = di.sl<GetProfile>();

      // Create and login test user
      testEmail =
          'logout_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(testEmail!, TestConfig.testPassword, 'Logout Test User');
      await login(testEmail!, TestConfig.testPassword);
    });

    setUp(() {
      logout = di.sl<Logout>();
    });

    test('5.1. Logout when authenticated', () async {
      TestHelper.printSection('TEST 5.1: LOGOUT WHEN AUTHENTICATED');

      TestHelper.printStep('Logging out...');

      final result = await logout();

      result.fold(
        (failure) {
          TestHelper.printError('Logout failed: ${failure.message}');
          fail('Should be able to logout when authenticated');
        },
        (_) {
          TestHelper.printSuccess('Logout successful');
        },
      );

      // Verify token is cleared
      final profileResult = await getProfile();
      profileResult.fold(
        (failure) => TestHelper.printSuccess('Token cleared successfully'),
        (user) => fail('Profile should not be accessible after logout'),
      );
    });

    test('5.2. Multiple consecutive logouts', () async {
      TestHelper.printSection('TEST 5.2: MULTIPLE CONSECUTIVE LOGOUTS');

      // Login first
      await login(testEmail!, TestConfig.testPassword);

      TestHelper.printStep('Performing 3 consecutive logouts');

      for (int i = 1; i <= 3; i++) {
        TestHelper.printStep('Logout attempt $i');

        final result = await logout();

        result.fold(
          (failure) =>
              TestHelper.printError('Logout $i failed: ${failure.message}'),
          (_) => TestHelper.printSuccess('Logout $i successful'),
        );
      }

      TestHelper.printSuccess('All logouts completed');
    });

    test('5.3. Login after logout', () async {
      TestHelper.printSection('TEST 5.3: LOGIN AFTER LOGOUT');

      TestHelper.printStep('Logging out...');
      await logout();

      TestHelper.printStep('Attempting to login again...');
      final result = await login(testEmail!, TestConfig.testPassword);

      result.fold(
        (failure) {
          TestHelper.printError(
            'Login after logout failed: ${failure.message}',
          );
          fail('Should be able to login after logout');
        },
        (user) {
          TestHelper.printSuccess('Login after logout successful');
          expect(user.email, testEmail);
        },
      );
    });
  });

  group('6. Session Management Tests -', () {
    late Register register;
    late Login login;
    late GetProfile getProfile;
    late UpdateProfile updateProfile;
    late Logout logout;

    String? testEmail;

    setUpAll(() async {
      register = di.sl<Register>();
      login = di.sl<Login>();
      getProfile = di.sl<GetProfile>();
      updateProfile = di.sl<UpdateProfile>();
      logout = di.sl<Logout>();

      testEmail =
          'session_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(testEmail!, TestConfig.testPassword, 'Session Test User');
    });

    test('6.1. Operations require authentication', () async {
      TestHelper.printSection('TEST 6.1: OPERATIONS REQUIRE AUTH');

      TestHelper.printStep('Ensuring logged out...');
      await logout();

      TestHelper.printStep('1. Get profile without auth');
      final profileResult = await getProfile();
      expect(profileResult.isLeft(), true);

      TestHelper.printStep('2. Update profile without auth');
      final updateResult = await updateProfile(name: 'New Name');
      expect(updateResult.isLeft(), true);

      TestHelper.printSuccess('All protected operations blocked (as expected)');
    });

    test('6.2. Session persists across requests', () async {
      TestHelper.printSection('TEST 6.2: SESSION PERSISTS');

      TestHelper.printStep('Logging in...');
      await login(testEmail!, TestConfig.testPassword);

      TestHelper.printStep('Making multiple authenticated requests');

      // Request 1
      final result1 = await getProfile();
      expect(result1.isRight(), true);
      TestHelper.printSuccess('Request 1: Success');

      // Request 2
      final result2 = await updateProfile(name: 'Name Update 1');
      expect(result2.isRight(), true);
      TestHelper.printSuccess('Request 2: Success');

      // Request 3
      final result3 = await getProfile();
      expect(result3.isRight(), true);
      TestHelper.printSuccess('Request 3: Success');

      TestHelper.printSuccess('Session persisted across all requests');
    });

    test('6.3. Login overwrites previous session', () async {
      TestHelper.printSection('TEST 6.3: LOGIN OVERWRITES SESSION');

      // Login with first user
      final email1 =
          'user1_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(email1, TestConfig.testPassword, 'User 1');
      await login(email1, TestConfig.testPassword);

      var profile = await getProfile();
      profile.fold((_) => fail('Should get profile'), (user) {
        TestHelper.printSuccess('User 1 logged in: ${user.email}');
        expect(user.email, email1);
      });

      // Login with second user (should overwrite session)
      final email2 =
          'user2_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await register(email2, TestConfig.testPassword, 'User 2');
      await login(email2, TestConfig.testPassword);

      profile = await getProfile();
      profile.fold((_) => fail('Should get profile'), (user) {
        TestHelper.printSuccess('User 2 logged in: ${user.email}');
        expect(user.email, email2);
        expect(user.email, isNot(email1));
      });

      TestHelper.printSuccess('Session overwritten successfully');
    });
  });

  tearDownAll(() async {
    TestHelper.printSection('CLEANING UP');
    TestHelper.printSuccess('All auth tests completed');
    TestHelper.printStep('Test users remain in database for inspection');
  });
}
