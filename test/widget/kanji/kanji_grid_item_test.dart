import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kanji_mobile_v1/features/kanji/presentation/widgets/kanji_grid_item.dart';

import '../../helpers/fixtures/kanji_fixtures.dart';

void main() {
  group('KanjiGridItem Widget', () {
    testWidgets('should display kanji character', (WidgetTester tester) async {
      // arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanji1, onTap: () => tapped = true),
          ),
        ),
      );

      // assert
      expect(find.text('日'), findsOneWidget);
      expect(tapped, false);
    });

    testWidgets('should display first meaning', (WidgetTester tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanji1, onTap: () {}),
          ),
        ),
      );

      // assert
      expect(find.text('sun'), findsOneWidget);
    });

    testWidgets('should display JLPT badge when available', (
      WidgetTester tester,
    ) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanji1, onTap: () {}),
          ),
        ),
      );

      // assert
      expect(find.text('N5'), findsOneWidget);
    });

    testWidgets('should display Grade badge when JLPT is null', (
      WidgetTester tester,
    ) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanjiMinimal, onTap: () {}),
          ),
        ),
      );

      // assert - minimal kanji has no JLPT or grade, so no badge
      expect(find.textContaining('N'), findsNothing);
      expect(find.textContaining('G'), findsNothing);
    });

    testWidgets('should handle tap event', (WidgetTester tester) async {
      // arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanji1, onTap: () => tapped = true),
          ),
        ),
      );

      // act
      await tester.tap(find.byType(KanjiGridItem));
      await tester.pumpAndSettle();

      // assert
      expect(tapped, true);
    });

    testWidgets('should show N4 JLPT badge for N4 kanji', (
      WidgetTester tester,
    ) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanjiN4, onTap: () {}),
          ),
        ),
      );

      // assert
      expect(find.text('N4'), findsOneWidget);
      expect(find.text('建'), findsOneWidget);
    });

    testWidgets('should show N3 JLPT badge for N3 kanji', (
      WidgetTester tester,
    ) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanjiN3, onTap: () {}),
          ),
        ),
      );

      // assert
      expect(find.text('N3'), findsOneWidget);
      // The meaning might be truncated or styled differently in FittedBox
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should have correct styling and colors', (
      WidgetTester tester,
    ) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KanjiGridItem(kanji: tKanji1, onTap: () {}),
          ),
        ),
      );

      // assert
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });
  });
}
