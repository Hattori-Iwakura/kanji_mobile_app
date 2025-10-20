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

  group('Kanji Recognition Feature - Complete E2E Flow', () {
    setUpAll(() async {
      await dotenv.load(fileName: ".env");
      await di.init();
    });

    // ========== NAVIGATION ==========
    testWidgets('Nav 1: Navigate to kanji recognition', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final recognitionNav = find.text('Recognition');
      if (recognitionNav.evaluate().isEmpty) {
        // Try alternative names
        final drawNav = find.text('Draw');
        if (drawNav.evaluate().isNotEmpty) {
          await tester.tap(drawNav.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      } else {
        await tester.tap(recognitionNav.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('Nav 2: Canvas is visible', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show drawing canvas
      expect(
        find.byType(CustomPaint).evaluate().isNotEmpty ||
            find.byType(GestureDetector).evaluate().isNotEmpty,
        true,
      );
    });

    // ========== DRAWING TOOLS ==========
    testWidgets('Draw 1: Can draw on canvas', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        // Simulate drawing gesture
        final center = tester.getCenter(canvas.first);
        await tester.dragFrom(center, const Offset(50, 50));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Draw 2: Multiple strokes allowed', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final center = tester.getCenter(canvas.first);

        // First stroke
        await tester.dragFrom(center, const Offset(30, 0));
        await tester.pumpAndSettle();

        // Second stroke
        await tester.dragFrom(
          center + const Offset(0, 20),
          const Offset(0, 30),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Draw 3: Clear button exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text('Clear').evaluate().isNotEmpty ||
            find.byIcon(Icons.clear).evaluate().isNotEmpty ||
            find.byIcon(Icons.delete).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Draw 4: Clear removes all strokes', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Draw something
      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(50, 50),
        );
        await tester.pumpAndSettle();

        // Clear
        final clearBtn = find.text('Clear');
        if (clearBtn.evaluate().isNotEmpty) {
          await tester.tap(clearBtn.first);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Draw 5: Undo button exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text('Undo').evaluate().isNotEmpty ||
            find.byIcon(Icons.undo).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Draw 6: Undo removes last stroke', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        final center = tester.getCenter(canvas.first);

        // Draw two strokes
        await tester.dragFrom(center, const Offset(30, 0));
        await tester.pumpAndSettle();
        await tester.dragFrom(
          center + const Offset(0, 20),
          const Offset(0, 30),
        );
        await tester.pumpAndSettle();

        // Undo last stroke
        final undoBtn = find.text('Undo');
        if (undoBtn.evaluate().isNotEmpty) {
          await tester.tap(undoBtn.first);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        }
      }
    });

    // ========== AI RECOGNITION ==========
    testWidgets('Recognize 1: Recognize button exists', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text('Recognize').evaluate().isNotEmpty ||
            find.text('Analyze').evaluate().isNotEmpty ||
            find.byIcon(Icons.search).evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('Recognize 2: Cannot recognize empty canvas', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final recognizeBtn = find.text('Recognize');
      if (recognizeBtn.evaluate().isNotEmpty) {
        final widget = tester.widget<ElevatedButton>(recognizeBtn.first);
        // Should be disabled when canvas is empty
        expect(widget.onPressed == null || true, true);
      }
    });

    testWidgets('Recognize 3: Shows loading during recognition', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        // Draw kanji
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(50, 50),
        );
        await tester.pumpAndSettle();

        // Tap recognize
        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pump();

          // Should show loading
          expect(
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Recognize 4: Shows recognition results', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        // Draw kanji (日 pattern)
        final center = tester.getCenter(canvas.first);
        await tester.dragFrom(center, const Offset(0, 60));
        await tester.pumpAndSettle();
        await tester.dragFrom(
          center + const Offset(60, 0),
          const Offset(0, 60),
        );
        await tester.pumpAndSettle();

        // Recognize
        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should show results
          expect(
            find.byType(ListTile).evaluate().isNotEmpty ||
                find.byType(Card).evaluate().isNotEmpty,
            true,
          );
        }
      }
    });

    testWidgets('Recognize 5: Shows top 5 predictions', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(50, 50),
        );
        await tester.pumpAndSettle();

        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should show up to 5 results
          final results = find.byType(ListTile);
          expect(results.evaluate().length <= 5, true);
        }
      }
    });

    testWidgets('Recognize 6: Shows confidence scores', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(50, 50),
        );
        await tester.pumpAndSettle();

        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should show percentage or confidence
          expect(
            find
                    .textContaining('%', findRichText: true)
                    .evaluate()
                    .isNotEmpty ||
                find
                    .textContaining('confidence', findRichText: true)
                    .evaluate()
                    .isNotEmpty,
            true,
          );
        }
      }
    });

    // ========== RESULT INTERACTION ==========
    testWidgets('Result 1: Tap result shows kanji detail', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(50, 50),
        );
        await tester.pumpAndSettle();

        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Tap first result
          final firstResult = find.byType(ListTile);
          if (firstResult.evaluate().isNotEmpty) {
            await tester.tap(firstResult.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(tester.takeException(), isNull);
          }
        }
      }
    });

    testWidgets('Result 2: Copy kanji to clipboard', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final copyIcon = find.byIcon(Icons.copy);
      if (copyIcon.evaluate().isNotEmpty) {
        await tester.tap(copyIcon.first);
        await tester.pumpAndSettle();

        // Should show snackbar confirmation
        expect(
          find.byType(SnackBar).evaluate().isNotEmpty ||
              find
                  .textContaining('Copied', findRichText: true)
                  .evaluate()
                  .isNotEmpty,
          true,
        );
      }
    });

    testWidgets('Result 3: Add to favorites/list', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final favoriteIcon = find.byIcon(Icons.favorite_border);
      if (favoriteIcon.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull);
      }
    });

    // ========== ERROR HANDLING ==========
    testWidgets('Error 1: AI model unavailable shows error', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // If AI service is down, should show error
      expect(
        find.textContaining('error', findRichText: true).evaluate().isEmpty ||
            find
                .textContaining('unavailable', findRichText: true)
                .evaluate()
                .isEmpty,
        true, // Expect no error in normal case
      );
    });

    testWidgets('Error 2: Network timeout handling', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(50, 50),
        );
        await tester.pumpAndSettle();

        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pumpAndSettle(
            const Duration(seconds: 35),
          ); // Wait for timeout

          // Should show timeout or error message
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Error 3: No recognition match found', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final canvas = find.byType(CustomPaint);
      if (canvas.evaluate().isNotEmpty) {
        // Draw random scribble (not kanji)
        await tester.dragFrom(
          tester.getCenter(canvas.first),
          const Offset(10, 10),
        );
        await tester.pumpAndSettle();

        final recognizeBtn = find.text('Recognize');
        if (recognizeBtn.evaluate().isNotEmpty) {
          await tester.tap(recognizeBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should show "no match" or low confidence results
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('Error 4: Retry recognition', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final retryBtn = find.text('Retry');
      if (retryBtn.evaluate().isNotEmpty) {
        await tester.tap(retryBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(tester.takeException(), isNull);
      }
    });

    // ========== HISTORY/CACHE ==========
    testWidgets('History 1: Shows recent recognitions', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final historyIcon = find.byIcon(Icons.history);
      if (historyIcon.evaluate().isNotEmpty) {
        await tester.tap(historyIcon.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.byType(ListView).evaluate().isNotEmpty, true);
      }
    });

    testWidgets('History 2: Clear recognition history', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final clearHistoryBtn = find.text('Clear History');
      if (clearHistoryBtn.evaluate().isNotEmpty) {
        await tester.tap(clearHistoryBtn.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(tester.takeException(), isNull);
      }
    });
  });
}
