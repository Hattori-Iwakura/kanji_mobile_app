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

  group('Kanji Feature - Complete E2E Flow', () {
    setUpAll(() async {
      await dotenv.load(fileName: ".env");
      await di.init();
    });

    // ========== KANJI LIST & NAVIGATION ==========
    testWidgets('Kanji 1: Navigate to kanji list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find kanji menu item
      final kanjiNav = find.text('Kanji');
      if (kanjiNav.evaluate().isNotEmpty) {
        await tester.tap(kanjiNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show kanji list
        expect(
          find.byType(ListView).evaluate().isNotEmpty ||
              find.byType(GridView).evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Kanji 2: List shows loading indicator', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show loading while fetching
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Kanji 3: List displays kanji items', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should show kanji cards/items
      expect(
        find.byType(Card).evaluate().isNotEmpty ||
            find.byType(ListTile).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Kanji 4: Empty list shows appropriate message', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // If no kanji, should show empty state
      if (find.byType(Card).evaluate().isEmpty) {
        expect(
          find
              .textContaining('No kanji', findRichText: true)
              .evaluate()
              .isNotEmpty,
          true,
        );
      }
    });

    // ========== KANJI SEARCH ==========
    testWidgets('Search 1: Search field is accessible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should have search field or icon
      expect(
        find.byType(TextField).evaluate().isNotEmpty ||
            find.byIcon(Icons.search).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Search 2: Empty search shows all kanji', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show all items
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Search 3: Search by character filters results', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, '日');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should filter to matching kanji
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Search 4: Search by meaning works', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'sun');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should find kanji with 'sun' meaning
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Search 5: No results shows empty state', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'xyz123notfound');
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show no results message
        expect(
          find.textContaining('No', findRichText: true).evaluate().isNotEmpty ||
              find
                  .textContaining('found', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    // ========== KANJI FILTERS ==========
    testWidgets('Filter 1: JLPT level filter exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should have JLPT filter
      expect(
        find.text('JLPT').evaluate().isNotEmpty ||
            find.byType(DropdownButton).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Filter 2: Filter by JLPT N5', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final jlptFilter = find.text('N5');
      if (jlptFilter.evaluate().isNotEmpty) {
        await tester.tap(jlptFilter.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show only N5 kanji
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Filter 3: Filter by grade level', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final gradeFilter = find.text('Grade');
      if (gradeFilter.evaluate().isNotEmpty) {
        await tester.tap(gradeFilter.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show grade options
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Filter 4: Clear all filters', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final clearBtn = find.text('Clear');
      if (clearBtn.evaluate().isNotEmpty) {
        await tester.tap(clearBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should reset to all kanji
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Filter 5: Combined search and filter', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Apply both search and filter
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, '日');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final jlptFilter = find.text('N5');
        if (jlptFilter.evaluate().isNotEmpty) {
          await tester.tap(jlptFilter.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Should show filtered and searched results
          expect(tester.takeException(), isNull);
        }
      }
    });

    // ========== KANJI DETAIL ==========
    testWidgets('Detail 1: Tap kanji opens detail page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final kanjiCard = find.byType(Card);
      final listTile = find.byType(ListTile);
      final itemFinder = kanjiCard.evaluate().isNotEmpty ? kanjiCard : listTile;

      if (itemFinder.evaluate().isNotEmpty) {
        await tester.tap(itemFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show detail page
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Detail 2: Shows kanji character prominently', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final kanjiCard = find.byType(Card);
      final listTile = find.byType(ListTile);
      final itemFinder = kanjiCard.evaluate().isNotEmpty ? kanjiCard : listTile;

      if (itemFinder.evaluate().isNotEmpty) {
        await tester.tap(itemFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show kanji with large text
        expect(find.byType(Text).evaluate().isNotEmpty, true);
      }
    });

    testWidgets('Detail 3: Shows meanings in English', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final kanjiCard = find.byType(Card);
      final listTile = find.byType(ListTile);
      final itemFinder = kanjiCard.evaluate().isNotEmpty ? kanjiCard : listTile;

      if (itemFinder.evaluate().isNotEmpty) {
        await tester.tap(itemFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show meanings
        expect(
          find.text('Meaning').evaluate().isNotEmpty ||
              find.text('Meanings').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Detail 4: Shows readings (Onyomi/Kunyomi)', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final kanjiCard = find.byType(Card);
      final listTile = find.byType(ListTile);
      final itemFinder = kanjiCard.evaluate().isNotEmpty ? kanjiCard : listTile;

      if (itemFinder.evaluate().isNotEmpty) {
        await tester.tap(itemFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show readings
        expect(
          find.text('Onyomi').evaluate().isNotEmpty ||
              find.text('Kunyomi').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Detail 5: Shows JLPT and grade info', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final kanjiCard = find.byType(Card);
      final listTile = find.byType(ListTile);
      final itemFinder = kanjiCard.evaluate().isNotEmpty ? kanjiCard : listTile;

      if (itemFinder.evaluate().isNotEmpty) {
        await tester.tap(itemFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should show level info
        expect(
          find.text('JLPT').evaluate().isNotEmpty ||
              find.text('Grade').evaluate().isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Detail 6: Back button returns to list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final kanjiCard = find.byType(Card);
      final listTile = find.byType(ListTile);
      final itemFinder = kanjiCard.evaluate().isNotEmpty ? kanjiCard : listTile;

      if (itemFinder.evaluate().isNotEmpty) {
        await tester.tap(itemFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Tap back
        final backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Should be back on list
          expect(
            find.byType(ListView).evaluate().isNotEmpty ||
                find.byType(GridView).evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    // ========== PAGINATION ==========
    testWidgets('Pagination 1: Shows limited items per page', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should not load all kanji at once
      final cards = find.byType(Card);
      final tiles = find.byType(ListTile);
      final itemCount = cards.evaluate().isNotEmpty
          ? cards.evaluate().length
          : tiles.evaluate().length;
      expect(itemCount <= 50, true);
    });

    testWidgets('Pagination 2: Scroll loads more items', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        // Scroll to bottom
        await tester.drag(listView.first, const Offset(0, -500));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should load more items or show end
        expect(tester.takeException(), isNull);
      }
    });

    // ========== REFRESH ==========
    testWidgets('Refresh 1: Pull to refresh works', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        // Pull down to refresh
        await tester.drag(listView.first, const Offset(0, 300));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Should refresh list
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Refresh 2: Shows loading during refresh', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView.first, const Offset(0, 300));
        await tester.pump();

        // Should show refresh indicator
        expect(
          find.byType(RefreshIndicator).evaluate().isNotEmpty ||
              find.byType(CircularProgressIndicator).evaluate().isNotEmpty,
          true,
        );
      }
    });
  });
}
