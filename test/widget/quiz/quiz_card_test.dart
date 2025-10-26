import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/widgets/quiz_card.dart';

import '../../helpers/fixtures/quiz_fixtures.dart';

void main() {
  group('QuizCard Widget', () {
    testWidgets('should display quiz title', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () => tapped = true),
          ),
        ),
      );

      // assert
      expect(find.text('JLPT N5 Practice Quiz'), findsOneWidget);
    });

    testWidgets('should display quiz description', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () => tapped = true),
          ),
        ),
      );

      // assert
      expect(find.text('Test your basic kanji knowledge'), findsOneWidget);
    });

    testWidgets('should display difficulty badge with correct color', (
      tester,
    ) async {
      // arrange
      bool tapped = false;

      // act - EASY quiz
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: tQuiz1, // EASY
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // assert
      expect(find.text('EASY'), findsOneWidget);
    });

    testWidgets('should display total questions count', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () => tapped = true),
          ),
        ),
      );

      // assert
      expect(find.text('10 Questions'), findsOneWidget);
    });

    testWidgets('should display time limit when available', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: tQuiz1, // has 600s time limit
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // assert
      expect(find.text('10 min'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('should display passing score', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: tQuiz1, // 70% passing
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // assert
      expect(find.text('Pass: 70%'), findsOneWidget);
    });

    testWidgets('should display Start Quiz button', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () => tapped = true),
          ),
        ),
      );

      // assert
      expect(find.text('Start Quiz'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // assert
      expect(tapped, true);
    });

    testWidgets('should call onTap when Start Quiz button is tapped', (
      tester,
    ) async {
      // arrange
      bool tapped = false;

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Start Quiz'));
      await tester.pumpAndSettle();

      // assert
      expect(tapped, true);
    });

    testWidgets('should show different colors for different difficulties', (
      tester,
    ) async {
      // Test EASY (green)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: tQuiz1, // EASY
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('EASY'), findsOneWidget);

      // Test MEDIUM (orange)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: tQuiz2, // MEDIUM
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('MEDIUM'), findsOneWidget);

      // Test HARD (red)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(
              quiz: tQuiz3, // HARD
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('HARD'), findsOneWidget);
    });

    testWidgets('should display all info chips', (tester) async {
      // arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizCard(quiz: tQuiz1, onTap: () {}),
          ),
        ),
      );

      // assert - check icons
      expect(find.byIcon(Icons.quiz), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
