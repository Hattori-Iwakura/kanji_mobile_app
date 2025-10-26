import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';

void main() {
  Widget createQuestionFormWidget() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Create Question',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Question Type Selector
              const Text(
                'Question Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Multiple Choice'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text('True/False'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text('Fill in Blank'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text('Drawing'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Question Text Field
              TextFormField(
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Enter your question here...',
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Points Field
              TextFormField(
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Points',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Explanation Field
              TextFormField(
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Explanation (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: 'Explain the correct answer...',
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Create Question'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('CreateQuestionPage UI', () {
    testWidgets('should display page title', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert - found in both AppBar and button, use findsWidgets
      expect(find.text('Create Question'), findsWidgets);
    });

    testWidgets('should display question type label', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.text('Question Type'), findsOneWidget);
    });

    testWidgets('should display all question type chips', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.text('Multiple Choice'), findsOneWidget);
      expect(find.text('True/False'), findsOneWidget);
      expect(find.text('Fill in Blank'), findsOneWidget);
      expect(find.text('Drawing'), findsOneWidget);
    });

    testWidgets('should display question text field', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.widgetWithText(TextFormField, 'Question'), findsOneWidget);
      expect(find.text('Enter your question here...'), findsOneWidget);
    });

    testWidgets('should display points field', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.widgetWithText(TextFormField, 'Points'), findsOneWidget);
    });

    testWidgets('should display explanation field', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(
        find.widgetWithText(TextFormField, 'Explanation (Optional)'),
        findsOneWidget,
      );
      expect(find.text('Explain the correct answer...'), findsOneWidget);
    });

    testWidgets('should display create button icon', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should have multiple choice selected by default', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      final choiceChips = tester.widgetList<ChoiceChip>(
        find.byType(ChoiceChip),
      );
      expect(choiceChips.first.selected, true);
    });

    testWidgets('should display all form fields in ListView', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.byType(ListView), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(3),
      ); // question, points, explanation
    });

    testWidgets('should have Form widget', (tester) async {
      // act
      await tester.pumpWidget(createQuestionFormWidget());

      // assert
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
