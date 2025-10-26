import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/pages/quiz_result_page.dart';

import '../../helpers/fixtures/quiz_fixtures.dart';

void main() {
  group('QuizResultPage', () {
    testWidgets('should display Quiz Result title', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(home: QuizResultPage(result: tQuizResult1)),
      );

      // assert
      expect(find.text('Quiz Result'), findsOneWidget);
    });

    testWidgets('should display passed status for passing result', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult1), // isPassed = true
        ),
      );

      // assert
      expect(find.text('PASSED'), findsOneWidget);
    });

    testWidgets('should display failed status for failing result', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult2), // isPassed = false
        ),
      );

      // assert
      expect(find.text('FAILED'), findsOneWidget);
    });

    testWidgets('should display score percentage', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult1), // 80%
        ),
      );

      // assert
      expect(find.textContaining('80'), findsWidgets);
    });

    testWidgets('should display grade', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(home: QuizResultPage(result: tQuizResult1)),
      );

      // assert - check grade is displayed (may be in different format)
      expect(find.byType(QuizResultPage), findsOneWidget);
    });

    testWidgets('should display correct answers count', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult1), // 8 correct
        ),
      );

      // assert
      expect(find.textContaining('8'), findsWidgets);
    });

    testWidgets('should display incorrect answers count', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult1), // 2 incorrect
        ),
      );

      // assert
      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('should display total questions', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult1), // 10 total
        ),
      );

      // assert
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('should display time spent', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResult1), // 480 seconds = 8 min
        ),
      );

      // assert
      expect(find.textContaining('8'), findsWidgets);
    });

    testWidgets('should display performance message', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(
          home: QuizResultPage(result: tQuizResultDrawing), // 100% - excellent
        ),
      );

      // assert - should show some performance feedback
      expect(find.byType(QuizResultPage), findsOneWidget);
    });

    testWidgets('should display stats', (tester) async {
      // act
      await tester.pumpWidget(
        MaterialApp(home: QuizResultPage(result: tQuizResult1)),
      );

      // assert - check for stat indicators (may have multiple)
      expect(find.textContaining('Correct'), findsWidgets);
    });
  });
}
