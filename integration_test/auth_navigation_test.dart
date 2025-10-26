import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kanji_mobile_v1/main.dart' as app;

/// Integration test for authentication navigation flow
/// Tests: Login → Home → Logout → Login
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Navigation Flow Integration Tests', () {
    testWidgets(
      'should navigate from login to home after successful authentication',
      (WidgetTester tester) async {
        // Start app
        app.main();
        await tester.pumpAndSettle();

        // Verify we're on login page
        expect(find.text('Login'), findsOneWidget);
        expect(find.byKey(const Key('email_field')), findsOneWidget);
        expect(find.byKey(const Key('password_field')), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);

        // Enter credentials
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'nsm@gmail.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'Hutaomywife1225',
        );
        await tester.pumpAndSettle();

        // Tap login button
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verify navigation to home page
        // Should see bottom navigation bar with tabs
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Kanji'), findsOneWidget);
        expect(find.text('Flashcard'), findsOneWidget);
        expect(find.text('Quiz'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);

        // Verify login page is not visible
        expect(find.byKey(const Key('login_button')), findsNothing);
      },
    );

    testWidgets(
      'should show error and stay on login page for invalid credentials',
      (WidgetTester tester) async {
        // Start app
        app.main();
        await tester.pumpAndSettle();

        // Enter invalid credentials
        await tester.enterText(
          find.byKey(const Key('email_field')),
          'invalid@test.com',
        );
        await tester.enterText(
          find.byKey(const Key('password_field')),
          'wrongpassword',
        );
        await tester.pumpAndSettle();

        // Tap login button
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should still be on login page
        expect(find.byKey(const Key('login_button')), findsOneWidget);

        // Should show error message
        expect(find.text('Invalid credentials'), findsOneWidget);

        // Should NOT navigate to home
        expect(find.byType(BottomNavigationBar), findsNothing);
      },
    );

    testWidgets('should navigate from login to register and back', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify on login page
      expect(find.text('Login'), findsOneWidget);

      // Find and tap "Create Account" or "Sign Up" button
      final signUpButton = find.text('Create Account');
      expect(signUpButton, findsOneWidget);
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify navigation to register page
      expect(find.text('Register'), findsOneWidget);
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_button')), findsOneWidget);

      // Go back to login
      final backToLoginButton = find.text('Back to Login');
      await tester.tap(backToLoginButton);
      await tester.pumpAndSettle();

      // Verify back on login page
      expect(find.text('Login'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('should logout and navigate back to login page', (
      WidgetTester tester,
    ) async {
      // Start app and login first
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'nsm@gmail.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Hutaomywife1225',
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify on home page
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Navigate to settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find and tap logout button
      final logoutButton = find.byKey(const Key('logout_button'));
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify navigation back to login page
      expect(find.text('Login'), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });
  });
}
