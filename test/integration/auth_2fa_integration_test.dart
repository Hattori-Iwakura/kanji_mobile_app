import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/features/auth/domain/usecases/register.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/login.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/logout.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/get_profile.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/setup_2fa.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/enable_2fa.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/disable_2fa.dart';
import 'package:kanji_mobile_app/features/auth/domain/usecases/send_email_otp.dart';
import '../helpers/test_helper.dart';
import '../helpers/test_config.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING AUTH INTEGRATION TESTS');
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');
  });

  group('Auth Integration Tests -', () {
    late Register register;
    late Login login;
    late Logout logout;
    late GetProfile getProfile;
    late Setup2FA setup2FA;
    late Enable2FA enable2FA;
    late Disable2FA disable2FA;
    late SendEmailOTP sendEmailOTP;

    String? userId;

    setUp(() {
      register = di.sl<Register>();
      login = di.sl<Login>();
      logout = di.sl<Logout>();
      getProfile = di.sl<GetProfile>();
      setup2FA = di.sl<Setup2FA>();
      enable2FA = di.sl<Enable2FA>();
      disable2FA = di.sl<Disable2FA>();
      sendEmailOTP = di.sl<SendEmailOTP>();
    });

    test('1. Register new user', () async {
      TestHelper.printSection('TEST 1: REGISTER NEW USER');

      TestHelper.printStep('Registering with email: ${TestConfig.testEmail}');

      final result = await register(
        TestConfig.testEmail,
        TestConfig.testPassword,
        TestConfig.testName,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Registration failed: ${failure.message}');
          // If user already exists, that's okay for testing
          if (!failure.message.toLowerCase().contains('already') &&
              !failure.message.toLowerCase().contains('exist')) {
            fail('Registration failed: ${failure.message}');
          } else {
            TestHelper.printSuccess(
              'User already exists - continuing with login',
            );
          }
        },
        (user) {
          userId = user.id.toString();
          TestHelper.printSuccess('User registered successfully');
          TestHelper.printSuccess('User ID: $userId');
          TestHelper.printSuccess('Email: ${user.email}');
          TestHelper.printSuccess('Name: ${user.name}');
          TestHelper.printSuccess('2FA Enabled: ${user.isTwoFactorEnabled}');
        },
      );
    });

    test('2. Login with credentials', () async {
      TestHelper.printSection('TEST 2: LOGIN');

      TestHelper.printStep('Logging in with email: ${TestConfig.testEmail}');

      final result = await login(TestConfig.testEmail, TestConfig.testPassword);

      result.fold(
        (failure) {
          TestHelper.printError('Login failed: ${failure.message}');
          fail('Login failed: ${failure.message}');
        },
        (user) {
          userId = user.id.toString();
          TestHelper.printSuccess('Login successful');
          TestHelper.printSuccess('User ID: ${user.id}');
          TestHelper.printSuccess('Email: ${user.email}');
          TestHelper.printSuccess('Name: ${user.name}');
          TestHelper.printSuccess('Role: ${user.role}');
          TestHelper.printSuccess('2FA Enabled: ${user.isTwoFactorEnabled}');

          expect(user.email, TestConfig.testEmail);
        },
      );
    });

    test('3. Get user profile', () async {
      TestHelper.printSection('TEST 3: GET PROFILE');

      TestHelper.printStep('Fetching user profile...');

      final result = await getProfile();

      result.fold(
        (failure) {
          TestHelper.printError('Get profile failed: ${failure.message}');
          fail('Get profile failed: ${failure.message}');
        },
        (user) {
          TestHelper.printSuccess('Profile retrieved successfully');
          TestHelper.printSuccess('User ID: ${user.id}');
          TestHelper.printSuccess('Email: ${user.email}');
          TestHelper.printSuccess('Name: ${user.name}');
          TestHelper.printSuccess('2FA Enabled: ${user.isTwoFactorEnabled}');

          expect(user.email, TestConfig.testEmail);
        },
      );
    });

    test('4. Setup 2FA - Generate QR Code', () async {
      TestHelper.printSection('TEST 4: SETUP 2FA');

      TestHelper.printStep('Requesting 2FA setup...');

      final result = await setup2FA();

      result.fold(
        (failure) {
          TestHelper.printError('2FA setup failed: ${failure.message}');
          fail('2FA setup failed: ${failure.message}');
        },
        (twoFactorSetup) {
          TestHelper.printSuccess('2FA setup successful');
          TestHelper.printSuccess('Secret: ${twoFactorSetup.secret}');
          TestHelper.printSuccess('QR Code URL: ${twoFactorSetup.qrCodeUrl}');
          TestHelper.printSuccess(
            'Backup Codes count: ${twoFactorSetup.backupCodes.length}',
          );

          if (twoFactorSetup.backupCodes.isNotEmpty) {
            TestHelper.printStep('Backup Codes:');
            for (int i = 0; i < twoFactorSetup.backupCodes.length; i++) {
              print('   ${i + 1}. ${twoFactorSetup.backupCodes[i]}');
            }
          }

          expect(twoFactorSetup.secret, isNotEmpty);
          expect(twoFactorSetup.qrCodeUrl, isNotEmpty);
          expect(twoFactorSetup.backupCodes, isNotEmpty);
        },
      );
    });

    test(
      '5. Send Email OTP to ${TestConfig.twoFactorTestEmail}',
      () async {
        TestHelper.printSection('TEST 5: SEND EMAIL OTP');

        TestHelper.printStep(
          'Sending OTP to: ${TestConfig.twoFactorTestEmail}',
        );
        TestHelper.printStep('Please check your email inbox...');

        final result = await sendEmailOTP();

        result.fold(
          (failure) {
            TestHelper.printError('Send OTP failed: ${failure.message}');
            fail('Send OTP failed: ${failure.message}');
          },
          (_) {
            TestHelper.printSuccess('OTP sent successfully!');
            TestHelper.printSuccess(
              'Check email: ${TestConfig.twoFactorTestEmail}',
            );
            TestHelper.printStep('Please retrieve the 6-digit code from email');
          },
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('6. Enable 2FA with manual code input', () async {
      TestHelper.printSection('TEST 6: ENABLE 2FA');

      TestHelper.printStep('NOTE: This test requires manual input');
      TestHelper.printStep('You need to:');
      TestHelper.printStep(
        '1. Check email ${TestConfig.twoFactorTestEmail} for OTP',
      );
      TestHelper.printStep(
        '2. Or use authenticator app with the QR code from test 4',
      );
      TestHelper.printStep('3. Run this test manually with actual code');

      // For automated testing, we skip actual enable
      // In real testing, uncomment and provide actual code
      /*
      const testCode = '123456'; // Replace with actual code
      final result = await enable2FA(testCode);

      result.fold(
        (failure) {
          TestHelper.printError('Enable 2FA failed: ${failure.message}');
          fail('Enable 2FA failed: ${failure.message}');
        },
        (user) {
          TestHelper.printSuccess('2FA enabled successfully');
          TestHelper.printSuccess('User 2FA Status: ${user.isTwoFactorEnabled}');
          expect(user.isTwoFactorEnabled, true);
        },
      );
      */

      TestHelper.printSuccess('Test skipped - requires manual code input');
    }, skip: true); // Skip for automated testing

    test('7. Login with 2FA code (if 2FA is enabled)', () async {
      TestHelper.printSection('TEST 7: LOGIN WITH 2FA');

      TestHelper.printStep('Attempting login with 2FA...');
      TestHelper.printStep(
        'NOTE: This will fail if 2FA is enabled without code',
      );

      final result = await login(TestConfig.testEmail, TestConfig.testPassword);

      result.fold(
        (failure) {
          if (failure.message.toLowerCase().contains('2fa') ||
              failure.message.toLowerCase().contains('two-factor')) {
            TestHelper.printSuccess('2FA is required (as expected)');
            TestHelper.printStep('To complete login, provide 2FA code:');
            TestHelper.printStep(
              'Use: login(email, password, twoFactorCode: "123456")',
            );
          } else {
            TestHelper.printError('Login failed: ${failure.message}');
          }
        },
        (user) {
          if (user.isTwoFactorEnabled) {
            TestHelper.printError('Login should require 2FA code');
            fail('Login succeeded without 2FA code when 2FA is enabled');
          } else {
            TestHelper.printSuccess('Login successful (2FA not enabled)');
            TestHelper.printSuccess('User: ${user.email}');
          }
        },
      );
    });

    test('8. Disable 2FA (if enabled)', () async {
      TestHelper.printSection('TEST 8: DISABLE 2FA');

      TestHelper.printStep('NOTE: This test requires manual input');
      TestHelper.printStep('You need to:');
      TestHelper.printStep('1. Provide current password');
      TestHelper.printStep(
        '2. Provide 2FA code from authenticator or email OTP',
      );

      // For automated testing, we skip actual disable
      // In real testing, uncomment and provide actual values
      /*
      const testCode = '123456'; // Replace with actual code
      final result = await disable2FA(
        password: TestConfig.testPassword,
        code: testCode,
      );

      result.fold(
        (failure) {
          TestHelper.printError('Disable 2FA failed: ${failure.message}');
          if (!failure.message.toLowerCase().contains('not enabled')) {
            fail('Disable 2FA failed: ${failure.message}');
          } else {
            TestHelper.printSuccess('2FA was not enabled');
          }
        },
        (user) {
          TestHelper.printSuccess('2FA disabled successfully');
          TestHelper.printSuccess('User 2FA Status: ${user.isTwoFactorEnabled}');
          expect(user.isTwoFactorEnabled, false);
        },
      );
      */

      TestHelper.printSuccess('Test skipped - requires manual code input');
    }, skip: true); // Skip for automated testing

    test('9. Logout', () async {
      TestHelper.printSection('TEST 9: LOGOUT');

      TestHelper.printStep('Logging out...');

      final result = await logout();

      result.fold(
        (failure) {
          TestHelper.printError('Logout failed: ${failure.message}');
          fail('Logout failed: ${failure.message}');
        },
        (_) {
          TestHelper.printSuccess('Logout successful');
        },
      );
    });

    test('10. Verify logout - Get profile should fail', () async {
      TestHelper.printSection('TEST 10: VERIFY LOGOUT');

      TestHelper.printStep('Attempting to get profile after logout...');

      final result = await getProfile();

      result.fold(
        (failure) {
          TestHelper.printSuccess('Profile request failed (as expected)');
          TestHelper.printSuccess('Reason: ${failure.message}');
        },
        (user) {
          TestHelper.printError(
            'Profile should not be accessible after logout',
          );
          fail('Profile accessible after logout: ${user.email}');
        },
      );
    });
  });

  group('Auth Error Handling Tests -', () {
    late Login login;

    setUp(() {
      login = di.sl<Login>();
    });

    test('1. Login with invalid credentials', () async {
      TestHelper.printSection('ERROR TEST 1: INVALID CREDENTIALS');

      TestHelper.printStep('Attempting login with wrong password...');

      final result = await login(TestConfig.testEmail, 'WrongPassword123');

      result.fold(
        (failure) {
          TestHelper.printSuccess('Login failed as expected');
          TestHelper.printSuccess('Error: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (user) {
          TestHelper.printError('Login should fail with wrong password');
          fail('Login succeeded with invalid credentials');
        },
      );
    });

    test('2. Login with non-existent email', () async {
      TestHelper.printSection('ERROR TEST 2: NON-EXISTENT EMAIL');

      TestHelper.printStep('Attempting login with non-existent email...');

      final result = await login(
        'nonexistent@example.com',
        TestConfig.testPassword,
      );

      result.fold(
        (failure) {
          TestHelper.printSuccess('Login failed as expected');
          TestHelper.printSuccess('Error: ${failure.message}');
          expect(failure.message, isNotEmpty);
        },
        (user) {
          TestHelper.printError('Login should fail with non-existent email');
          fail('Login succeeded with non-existent email');
        },
      );
    });
  });

  tearDownAll(() async {
    TestHelper.printSection('CLEANING UP');
    TestHelper.printSuccess('All tests completed');
    TestHelper.printStep('Note: Test user data remains in database');
    TestHelper.printStep('Email: ${TestConfig.testEmail}');
  });
}
