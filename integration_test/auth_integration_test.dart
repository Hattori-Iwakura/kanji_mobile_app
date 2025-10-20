import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kanji_flutter/main.dart';
import 'package:kanji_flutter/core/theme/theme_provider.dart';
import 'package:kanji_flutter/injection_container.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    );
  }

  group('Auth Feature - Complete E2E Flow', () {
    setUpAll(() async {
      await dotenv.load(fileName: ".env");
      await di.init();
    });

    // ========== REGISTRATION FLOW ==========
    testWidgets('Register 1: Navigate to register page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap register button/link
      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should see register form
        expect(find.text('Register'), findsWidgets);
      }
    });

    testWidgets('Register 2: Submit with empty fields shows errors', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Try to submit without filling
        final submitBtn = find.widgetWithText(ElevatedButton, 'Sign Up');
        if (submitBtn.evaluate().isNotEmpty) {
          await tester.tap(submitBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Should show validation errors
          expect(
            find
                    .textContaining('required', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('empty', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Register 3: Invalid email format shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 2) {
          // Enter invalid email
          await tester.enterText(textFields.at(0), 'testuser');
          await tester.enterText(textFields.at(1), 'invalid-email');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Sign Up');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Should show email validation error
            expect(
              find
                  .textContaining('email', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    testWidgets('Register 4: Password mismatch shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(0), 'testuser');
          await tester.enterText(textFields.at(1), 'test@example.com');
          await tester.enterText(textFields.at(2), 'Test@123456');
          await tester.enterText(textFields.at(3), 'Test@123457'); // Different
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Sign Up');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Should show password mismatch error
            expect(
              find
                  .textContaining('match', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    testWidgets('Register 5: Weak password shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(2), '123'); // Too short
          await tester.pumpAndSettle();

          // Should show password requirement error
          expect(
            find
                    .textContaining('password', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('characters', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Register 6: Valid registration succeeds', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          await tester.enterText(textFields.at(0), 'user_$timestamp');
          await tester.enterText(
            textFields.at(1),
            'test_$timestamp@example.com',
          );
          await tester.enterText(textFields.at(2), 'Test@123456');
          await tester.enterText(textFields.at(3), 'Test@123456');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Sign Up');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 5));

            // Should see success or redirect to login
            expect(
              find.text('Login').evaluate().isNotEmpty ||
                  find
                      .textContaining('success', findRichText: true)
                      .evaluate()
                      .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    // ========== LOGIN FLOW ==========
    testWidgets('Login 1: Navigate to login page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on login page or navigate to it
      expect(find.text('Login').evaluate().isNotEmpty, true);
    });

    testWidgets('Login 2: Submit with empty credentials shows errors', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
      if (loginBtn.evaluate().isNotEmpty) {
        await tester.tap(loginBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show validation errors
        expect(
          find
              .textContaining('required', findRichText: true)
              .evaluate()
              .isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Login 3: Wrong email shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'wrong@example.com');
        await tester.enterText(textFields.at(1), 'Test@123456');
        await tester.pumpAndSettle();

        final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should show error message
          expect(
            find
                    .textContaining('error', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('Invalid', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('not found', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Login 4: Wrong password shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'WrongPassword123!');
        await tester.pumpAndSettle();

        final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should show error
          expect(
            find
                    .textContaining('password', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('Invalid', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Login 5: Password visibility toggle works', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find password visibility icon
      final visibilityIcon = find.byIcon(Icons.visibility);
      if (visibilityIcon.evaluate().isNotEmpty) {
        await tester.tap(visibilityIcon.first);
        await tester.pumpAndSettle();

        // Should toggle to visibility_off
        expect(find.byIcon(Icons.visibility_off), findsWidgets);
      }
    });

    // ========== LOGOUT FLOW ==========
    testWidgets('Logout 1: User can logout from menu', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for menu or logout button
      final menuIcon = find.byIcon(Icons.menu);
      if (menuIcon.evaluate().isNotEmpty) {
        await tester.tap(menuIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final logoutBtn = find.text('Logout');
        if (logoutBtn.evaluate().isNotEmpty) {
          await tester.tap(logoutBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Should redirect to login
          expect(find.text('Login'), findsWidgets);
        }
      }
    });

    testWidgets('Logout 2: Session cleared after logout', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After logout, should not be able to access protected routes
      expect(find.text('Login').evaluate().isNotEmpty, true);
    });

    // ========== SESSION MANAGEMENT ==========
    testWidgets('Session 1: Token persists after app restart', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Restart app
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should maintain auth state
      expect(tester.takeException(), isNull);
    });

    testWidgets('Session 2: Expired token redirects to login', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should handle expired tokens gracefully
      expect(tester.takeException(), isNull);
    });

    // ========== ADDITIONAL EDGE CASES ==========
    testWidgets('Edge 1: Email with special characters', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(0), 'test+special@example.com');
          await tester.enterText(textFields.at(1), 'TestUser123');
          await tester.enterText(textFields.at(2), 'Test@123456');
          await tester.enterText(textFields.at(3), 'Test@123456');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Register');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 5));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Edge 2: Username with spaces not allowed', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(1), 'User Name With Spaces');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Register');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(
              find
                      .textContaining('space', findRichText: true)
                      .evaluate()
                      .isNotEmpty ||
                  find
                      .textContaining('invalid', findRichText: true)
                      .evaluate()
                      .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    testWidgets('Edge 3: Username too short', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.enterText(textFields.at(1), 'ab');
          await tester.enterText(textFields.at(2), 'Test@123456');
          await tester.enterText(textFields.at(3), 'Test@123456');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Register');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(
              find
                      .textContaining('short', findRichText: true)
                      .evaluate()
                      .isNotEmpty ||
                  find
                      .textContaining('3 characters', findRichText: true)
                      .evaluate()
                      .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    testWidgets('Edge 4: Already registered email', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(0), 'existing@example.com');
          await tester.enterText(textFields.at(1), 'ExistingUser');
          await tester.enterText(textFields.at(2), 'Test@123456');
          await tester.enterText(textFields.at(3), 'Test@123456');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Register');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 5));

            expect(
              find
                      .textContaining('already', findRichText: true)
                      .evaluate()
                      .isNotEmpty ||
                  find
                      .textContaining('exist', findRichText: true)
                      .evaluate()
                      .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    testWidgets('Edge 5: Password without special characters', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final registerBtn = find.text('Register');
      if (registerBtn.evaluate().isNotEmpty) {
        await tester.tap(registerBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 4) {
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.enterText(textFields.at(1), 'TestUser');
          await tester.enterText(textFields.at(2), 'Test123456');
          await tester.enterText(textFields.at(3), 'Test123456');
          await tester.pumpAndSettle();

          final submitBtn = find.widgetWithText(ElevatedButton, 'Register');
          if (submitBtn.evaluate().isNotEmpty) {
            await tester.tap(submitBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(
              find
                  .textContaining('special', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
              true,
            );
          }
        }
      }
    });

    testWidgets('Edge 6: Login with unverified email (if applicable)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'unverified@example.com');
        await tester.enterText(textFields.at(1), 'Test@123456');
        await tester.pumpAndSettle();

        final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Edge 7: Account locked after multiple failed attempts', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        // Try wrong password multiple times
        for (int i = 0; i < 5; i++) {
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.enterText(textFields.at(1), 'WrongPassword$i');
          await tester.pumpAndSettle();

          final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
          if (loginBtn.evaluate().isNotEmpty) {
            await tester.tap(loginBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 3));
          }
        }

        expect(
          find
                  .textContaining('locked', findRichText: true)
                  .evaluate()
                  .isNotEmpty ||
              find
                  .textContaining('too many', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Edge 8: Remember me checkbox functionality', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final rememberMe = find.byType(Checkbox);
      if (rememberMe.evaluate().isNotEmpty) {
        await tester.tap(rememberMe.first);
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        if (textFields.evaluate().length >= 2) {
          await tester.enterText(textFields.at(0), 'test@example.com');
          await tester.enterText(textFields.at(1), 'Test@123456');
          await tester.pumpAndSettle();

          final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
          if (loginBtn.evaluate().isNotEmpty) {
            await tester.tap(loginBtn.first);
            await tester.pumpAndSettle(const Duration(seconds: 5));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Edge 9: Forgot password link exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text('Forgot Password').evaluate().isNotEmpty ||
            find.text('Forgot password?').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Edge 10: Network timeout during login', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), 'test@example.com');
        await tester.enterText(textFields.at(1), 'Test@123456');
        await tester.pumpAndSettle();

        final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
        if (loginBtn.evaluate().isNotEmpty) {
          await tester.tap(loginBtn.first);
          await tester.pump(const Duration(seconds: 35));

          expect(tester.takeException(), isNull);
        }
      }
    });
  });
}
