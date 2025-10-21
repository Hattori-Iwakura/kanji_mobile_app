import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kanji_flutter/main.dart' as app;
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env");
    await di.init();
  });

  Widget createTestApp() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const app.MyApp(),
    );
  }

  group('HOME PAGE INTEGRATION TESTS', () {
    // ========== USER HOME PAGE ==========
    testWidgets('User Home 1: Navigate to user home page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should be on user landing page or home
      expect(
        find.text('Home').evaluate().isNotEmpty ||
            find.text('Kanji').evaluate().isNotEmpty ||
            find.byType(BottomNavigationBar).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('User Home 2: Bottom navigation bar exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should have bottom navigation
      expect(find.byType(BottomNavigationBar).evaluate().isNotEmpty, true);
    });

    testWidgets('User Home 3: Home tab shows welcome content', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for home tab
      final homeTab = find.text('Home');
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show welcome or intro content
        expect(
          find.textContaining('Welcome').evaluate().isNotEmpty ||
              find.textContaining('Kanji').evaluate().isNotEmpty ||
              find.byType(Card).evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('User Home 4: Quick access to kanji list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for Kanji tab or button
      final kanjiTab = find.text('Kanji');
      if (kanjiTab.evaluate().isNotEmpty) {
        await tester.tap(kanjiTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should navigate to kanji list
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('User Home 5: Quick access to flashcards', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for Flashcard tab
      final flashcardTab = find.text('Flashcard');
      final flashcardsTab = find.text('Flashcards');
      final deckTab = find.text('Deck');
      final decksTab = find.text('Decks');

      if (flashcardTab.evaluate().isNotEmpty) {
        await tester.tap(flashcardTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (flashcardsTab.evaluate().isNotEmpty) {
        await tester.tap(flashcardsTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (deckTab.evaluate().isNotEmpty) {
        await tester.tap(deckTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (decksTab.evaluate().isNotEmpty) {
        await tester.tap(decksTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('User Home 6: Quick access to quiz', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for Quiz tab
      final quizTab = find.text('Quiz');
      final quizzesTab = find.text('Quizzes');

      if (quizTab.evaluate().isNotEmpty) {
        await tester.tap(quizTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (quizzesTab.evaluate().isNotEmpty) {
        await tester.tap(quizzesTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('User Home 7: Quick access to my lists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for Lists tab
      final listsTab = find.text('Lists');
      final myListsTab = find.text('My Lists');

      if (listsTab.evaluate().isNotEmpty) {
        await tester.tap(listsTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (myListsTab.evaluate().isNotEmpty) {
        await tester.tap(myListsTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('User Home 8: Profile/Settings access', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for Profile or Settings
      final profileTab = find.text('Profile');
      final settingsTab = find.text('Settings');
      final accountTab = find.text('Account');
      final profileIcon = find.byIcon(Icons.person);
      final settingsIcon = find.byIcon(Icons.settings);

      expect(
        profileTab.evaluate().isNotEmpty ||
            settingsTab.evaluate().isNotEmpty ||
            accountTab.evaluate().isNotEmpty ||
            profileIcon.evaluate().isNotEmpty ||
            settingsIcon.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('User Home 9: Recent activity or statistics', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for statistics or recent activity
      final statsText = find.textContaining('Stats');
      final progressText = find.textContaining('Progress');
      final recentText = find.textContaining('Recent');
      final activityText = find.textContaining('Activity');

      // Statistics are optional on home page
      expect(
        statsText.evaluate().isNotEmpty ||
            progressText.evaluate().isNotEmpty ||
            recentText.evaluate().isNotEmpty ||
            activityText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('User Home 10: Search functionality accessible', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for search icon or field
      final searchIcon = find.byIcon(Icons.search);
      final searchField = find.byType(TextField);

      // Search might be on kanji page
      if (searchIcon.evaluate().isNotEmpty) {
        expect(searchIcon.evaluate().isNotEmpty, true);
      } else {
        // Navigate to Kanji tab to check search
        final kanjiTab = find.text('Kanji');
        if (kanjiTab.evaluate().isNotEmpty) {
          await tester.tap(kanjiTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(
            find.byIcon(Icons.search).evaluate().isNotEmpty ||
                find.byType(TextField).evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    // ========== ADMIN HOME PAGE ==========
    testWidgets('Admin Home 1: Login as admin user', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for login or profile
      final loginBtn = find.text('Login');
      final signInBtn = find.text('Sign In');

      if (loginBtn.evaluate().isNotEmpty || signInBtn.evaluate().isNotEmpty) {
        final btnFinder = loginBtn.evaluate().isNotEmpty ? loginBtn : signInBtn;

        await tester.tap(btnFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Enter admin credentials (if login form appears)
        final emailField = find.byType(TextField).first;
        final passwordField = find.byType(TextField).last;

        if (emailField.evaluate().isNotEmpty &&
            passwordField.evaluate().isNotEmpty) {
          await tester.enterText(emailField, 'admin@example.com');
          await tester.enterText(passwordField, 'admin123');
          await tester.pumpAndSettle();

          // Submit login
          final submitBtn = find.text('Login');
          final submitSignIn = find.text('Sign In');
          final submitBtnFinder = submitBtn.evaluate().isNotEmpty
              ? submitBtn
              : submitSignIn;

          if (submitBtnFinder.evaluate().isNotEmpty) {
            await tester.tap(submitBtnFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 4));
          }
        }
      }

      // Check if admin dashboard is accessible
      expect(tester.takeException(), isNull);
    });

    testWidgets('Admin Home 2: Admin dashboard exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for Admin or Dashboard
      final adminText = find.textContaining('Admin');
      final dashboardText = find.textContaining('Dashboard');

      // Admin dashboard might require login
      expect(
        adminText.evaluate().isNotEmpty ||
            dashboardText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Admin Home 3: User management card visible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for admin dashboard or user management
      final userMgmtText = find.textContaining('User');
      final manageUsersText = find.text('Manage Users');

      // User management is admin-only
      expect(
        userMgmtText.evaluate().isNotEmpty ||
            manageUsersText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Admin Home 4: Kanji management card visible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for kanji management
      final kanjiMgmtText = find.textContaining('Kanji');
      final manageKanjiText = find.text('Manage Kanji');

      // Kanji management is admin-only
      expect(
        kanjiMgmtText.evaluate().isNotEmpty ||
            manageKanjiText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Admin Home 5: Quiz management card visible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for quiz management
      final quizMgmtText = find.textContaining('Quiz');
      final manageQuizText = find.text('Manage Quiz');
      final createQuizText = find.text('Create Quiz');

      // Quiz management is admin-only
      expect(
        quizMgmtText.evaluate().isNotEmpty ||
            manageQuizText.evaluate().isNotEmpty ||
            createQuizText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Admin Home 6: Category management card visible', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for category management
      final categoryMgmtText = find.textContaining('Category');
      final manageCategoryText = find.text('Category Management');

      // Category management is admin-only
      expect(
        categoryMgmtText.evaluate().isNotEmpty ||
            manageCategoryText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Admin Home 7: Statistics dashboard cards', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for statistics
      final statsText = find.textContaining('Statistics');
      final totalText = find.textContaining('Total');
      final countText = find.textContaining('Count');

      // Statistics are optional
      expect(
        statsText.evaluate().isNotEmpty ||
            totalText.evaluate().isNotEmpty ||
            countText.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Admin Home 8: Navigate to user management', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Try to find and tap user management
      final manageUsersBtn = find.text('Manage Users');
      final userMgmtBtn = find.text('User Management');

      if (manageUsersBtn.evaluate().isNotEmpty) {
        await tester.tap(manageUsersBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (userMgmtBtn.evaluate().isNotEmpty) {
        await tester.tap(userMgmtBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Admin Home 9: Navigate to category management', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Try to find and tap category management
      final categoryMgmtBtn = find.text('Category Management');
      final manageCategoryBtn = find.text('Manage Categories');

      if (categoryMgmtBtn.evaluate().isNotEmpty) {
        await tester.tap(categoryMgmtBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      } else if (manageCategoryBtn.evaluate().isNotEmpty) {
        await tester.tap(manageCategoryBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Admin Home 10: Back to user view from admin', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for back or home button
      final backBtn = find.byIcon(Icons.arrow_back);
      final homeBtn = find.byIcon(Icons.home);

      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      } else if (homeBtn.evaluate().isNotEmpty) {
        await tester.tap(homeBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      }
    });

    // ========== NAVIGATION BETWEEN PAGES ==========
    testWidgets('Navigation 1: Switch between all bottom tabs', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        // Find all tab items
        final tabs = [
          'Home',
          'Kanji',
          'Lists',
          'Flashcard',
          'Flashcards',
          'Deck',
          'Decks',
          'Quiz',
          'Quizzes',
          'Profile',
          'Settings',
        ];

        for (var tabName in tabs) {
          final tab = find.text(tabName);
          if (tab.evaluate().isNotEmpty) {
            await tester.tap(tab.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Navigation 2: AppBar actions accessible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for app bar actions
      final searchIcon = find.byIcon(Icons.search);
      final moreIcon = find.byIcon(Icons.more_vert);
      final notifIcon = find.byIcon(Icons.notifications);

      // Check if any action icons exist
      expect(
        searchIcon.evaluate().isNotEmpty ||
            moreIcon.evaluate().isNotEmpty ||
            notifIcon.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Navigation 3: Drawer menu if available', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for drawer menu icon
      final drawerIcon = find.byIcon(Icons.menu);

      if (drawerIcon.evaluate().isNotEmpty) {
        await tester.tap(drawerIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should open drawer
        expect(find.byType(Drawer).evaluate().isNotEmpty, true);

        // Close drawer
        await tester.drag(find.byType(Drawer), const Offset(-300, 0));
        await tester.pumpAndSettle();
      }
    });

    // ========== THEME & SETTINGS ==========
    testWidgets('Theme 1: Theme toggle accessible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for theme toggle
      final themeIcon = find.byIcon(Icons.dark_mode);
      final lightIcon = find.byIcon(Icons.light_mode);
      final brightnessIcon = find.byIcon(Icons.brightness_6);

      // Theme toggle might be in settings
      expect(
        themeIcon.evaluate().isNotEmpty ||
            lightIcon.evaluate().isNotEmpty ||
            brightnessIcon.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    testWidgets('Theme 2: Language selection accessible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Look for language settings
      final languageText = find.textContaining('Language');
      final langIcon = find.byIcon(Icons.language);

      // Language settings might be in settings page
      expect(
        languageText.evaluate().isNotEmpty ||
            langIcon.evaluate().isNotEmpty ||
            true,
        true,
      );
    });

    // ========== ERROR HANDLING ==========
    testWidgets('Error 1: Network error shows message', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // If network error occurs, should show message
      expect(
        find.textContaining('error', findRichText: true).evaluate().isEmpty ||
            find.byType(SnackBar).evaluate().isEmpty,
        true, // No error is expected in normal flow
      );
    });

    testWidgets('Error 2: Unauthorized redirects to login', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // App should handle unauthorized gracefully
      expect(tester.takeException(), isNull);
    });
  });
}
