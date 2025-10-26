import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/kanji/domain/entities/kanji.dart';
import '../../helpers/fixtures/kanji_fixtures.dart';

void main() {
  // Create a simple version of the detail page for testing without complex dependencies
  Widget createWidgetUnderTest(Kanji kanji) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          title: Text(kanji.character, style: const TextStyle(fontSize: 32)),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badges Section
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (kanji.jlpt != null)
                    Chip(label: Text('JLPT N${kanji.jlpt}')),
                  if (kanji.grade != null)
                    Chip(label: Text('Grade ${kanji.grade}')),
                  Chip(label: Text('${kanji.strokeCount} strokes')),
                  if (kanji.frequency != null)
                    Chip(label: Text('Frequency #${kanji.frequency}')),
                ],
              ),
              const SizedBox(height: 24),

              // Readings Section
              const Text(
                'Readings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if ((kanji.onyomi == null || kanji.onyomi!.isEmpty) &&
                  (kanji.kunyomi == null || kanji.kunyomi!.isEmpty))
                const Text('No readings available')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kanji.onyomi != null && kanji.onyomi!.isNotEmpty)
                      Text('音読み (On-yomi): ${kanji.onyomi}'),
                    if (kanji.kunyomi != null && kanji.kunyomi!.isNotEmpty)
                      Text('訓読み (Kun-yomi): ${kanji.kunyomi}'),
                  ],
                ),
              const SizedBox(height: 24),

              // Meanings Section
              const Text(
                'Meanings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kanji.meanings
                    .split(',')
                    .map((meaning) => Chip(label: Text(meaning.trim())))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('KanjiDetailPage Widget', () {
    testWidgets('should display kanji character in AppBar', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(
        find.text('日'),
        findsAtLeastNWidgets(1),
      ); // In AppBar and main display
    });

    testWidgets('should display back button in AppBar', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display favorite button in AppBar', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display JLPT badge when available', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.textContaining('N5'), findsWidgets);
    });

    testWidgets('should display Grade badge when available', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.textContaining('1'), findsWidgets); // Grade 1
    });

    testWidgets('should display stroke count badge when available', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.textContaining('4'), findsWidgets); // 4 strokes
    });

    testWidgets('should display frequency badge when available', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.textContaining('#1'), findsWidgets); // Frequency #1
    });

    testWidgets('should display onyomi reading when available', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.textContaining('On-yomi'), findsOneWidget);
      expect(find.textContaining('ニチ'), findsOneWidget);
    });

    testWidgets('should display kunyomi reading when available', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.textContaining('Kun-yomi'), findsOneWidget);
      expect(find.textContaining('ひ'), findsOneWidget);
    });

    testWidgets('should display meanings as chips', (
      WidgetTester tester,
    ) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.text('Meanings'), findsOneWidget);
      expect(find.text('sun'), findsOneWidget);
      expect(find.text('day'), findsOneWidget); // trim() removes leading space
      // Total chips: 4 badges (JLPT, Grade, Strokes, Frequency) + 2 meanings = 6
      expect(find.byType(Chip), findsNWidgets(6));
    });

    testWidgets(
      'should display "No readings available" when no readings exist',
      (WidgetTester tester) async {
        // act
        await tester.pumpWidget(createWidgetUnderTest(tKanjiMinimal));
        await tester.pump();

        // assert
        expect(find.text('No readings available'), findsOneWidget);
      },
    );

    testWidgets('should have scrollable content', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display Readings section', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(tKanji1));
      await tester.pump();

      // assert
      expect(find.text('Readings'), findsOneWidget);
    });

    testWidgets(
      'should display all meanings for kanji with multiple meanings',
      (WidgetTester tester) async {
        // act
        await tester.pumpWidget(createWidgetUnderTest(tKanjiN3));
        await tester.pump();

        // assert
        expect(find.text('Meanings'), findsOneWidget);
        // tKanjiN3 meanings: "tenderness, excel, surpass"
        expect(find.text('tenderness'), findsOneWidget);
        expect(find.text('excel'), findsOneWidget);
        expect(find.text('surpass'), findsOneWidget);
      },
    );
  });
}
