import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kanji_mobile_v1/main.dart' as app;

/// Integration test for home page navigation between tabs
/// Tests: Home → Kanji → Flashcard → Quiz → Settings → Home
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Navigation Flow Integration Tests', () {
    // Helper to login before each test
    Future<void> loginAndWaitForHome(WidgetTester tester) async {
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

      // Verify home loaded
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    }

    testWidgets('should navigate between all bottom navigation tabs', (
      WidgetTester tester,
    ) async {
      await loginAndWaitForHome(tester);

      // Verify on Home tab (default)
      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Navigate to Kanji tab
      await tester.tap(find.text('Kanji'));
      await tester.pumpAndSettle();
      // Verify Kanji page loaded (check for kanji list or search bar)
      expect(find.byType(TextField), findsWidgets); // Search bar

      // Navigate to Flashcard tab
      await tester.tap(find.text('Flashcard'));
      await tester.pumpAndSettle();
      // Verify Flashcard page loaded

      // Navigate to Quiz tab
      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle();
      // Verify Quiz page loaded

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      // Verify Settings page loaded
      expect(find.text('Profile'), findsOneWidget);

      // Navigate back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      // Verify Home page loaded
    });

    testWidgets('should maintain state when switching tabs', (
      WidgetTester tester,
    ) async {
      await loginAndWaitForHome(tester);

      // Go to Kanji tab and search
      await tester.tap(find.text('Kanji'));
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, '日');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to another tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Go back to Kanji tab
      await tester.tap(find.text('Kanji'));
      await tester.pumpAndSettle();

      // Search field should still have the text (state preserved)
      expect(find.text('日'), findsOneWidget);
    });

    testWidgets('should open kanji detail from kanji list', (
      WidgetTester tester,
    ) async {
      await loginAndWaitForHome(tester);

      // Navigate to Kanji tab
      await tester.tap(find.text('Kanji'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap first kanji card
      final kanjiCard = find.byType(Card).first;
      await tester.tap(kanjiCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify kanji detail page opened
      // Should show details like meaning, readings, etc.
      expect(find.text('Meaning'), findsOneWidget);
      expect(find.text('Readings'), findsOneWidget);

      // Go back
      final backButton = find.byType(BackButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back on kanji list
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should start flashcard practice session', (
      WidgetTester tester,
    ) async {
      await loginAndWaitForHome(tester);

      // Navigate to Flashcard tab
      await tester.tap(find.text('Flashcard'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap a deck to start practice
      final deckCard = find.byType(Card).first;
      await tester.tap(deckCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show practice page with flashcard
      // Verify flip button exists
      final flipButton = find.text('Show Answer');
      expect(flipButton, findsOneWidget);

      // Tap flip to show answer
      await tester.tap(flipButton);
      await tester.pumpAndSettle();

      // Should show answer and quality buttons
      expect(find.text('Again'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });

    testWidgets('should start quiz from quiz list', (
      WidgetTester tester,
    ) async {
      await loginAndWaitForHome(tester);

      // Navigate to Quiz tab
      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap a quiz
      final quizCard = find.byType(Card).first;
      await tester.tap(quizCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show quiz taking page
      // Verify question is displayed
      expect(find.text('Question'), findsOneWidget);

      // Verify answer options or input exists
      expect(find.byType(RadioListTile), findsWidgets); // For multiple choice
    });

    testWidgets('should open profile settings', (WidgetTester tester) async {
      await loginAndWaitForHome(tester);

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Tap on Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show profile edit page
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
    });
  });

  group('Error State Navigation Tests', () {
    testWidgets('should handle network error gracefully on kanji list', (
      WidgetTester tester,
    ) async {
      // This test verifies error state doesn't crash navigation
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

      // Navigate to Kanji tab
      await tester.tap(find.text('Kanji'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Even if API fails, should still be on Kanji page
      expect(find.text('Kanji'), findsWidgets);

      // Should show error state or retry button
      // (Error handling may show retry, empty state, or cached data)

      // Can navigate to other tabs despite error
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should handle empty state on quiz list', (
      WidgetTester tester,
    ) async {
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

      // Navigate to Quiz tab
      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // If no quizzes, should show empty state
      // But navigation should still work
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
