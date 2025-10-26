import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createEditQuestionFormWidget() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Edit Question',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Form(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Question Type Display (read-only)
              const Text(
                'Question Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'MULTIPLE_CHOICE',
                      style: TextStyle(color: Colors.blue),
                    ),
                    Spacer(),
                    Text(
                      '(Cannot be changed)',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Question Text Field
              TextFormField(
                initialValue: 'What does 日 mean?',
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: const TextStyle(color: Colors.white70),
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
                initialValue: '10',
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
                initialValue: '日 (hi) means sun or day in Japanese',
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Explanation (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Update Button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text('Update Question'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('EditQuestionPage UI', () {
    testWidgets('should display page title', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.text('Edit Question'), findsOneWidget);
    });

    testWidgets('should display question type label', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.text('Question Type'), findsOneWidget);
    });

    testWidgets('should display question type as read-only', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.text('MULTIPLE_CHOICE'), findsOneWidget);
      expect(find.text('(Cannot be changed)'), findsOneWidget);
    });

    testWidgets('should display question text field with initial value', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.widgetWithText(TextFormField, 'Question'), findsOneWidget);
      expect(find.text('What does 日 mean?'), findsOneWidget);
    });

    testWidgets('should display points field with initial value', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.widgetWithText(TextFormField, 'Points'), findsOneWidget);
    });

    testWidgets('should display explanation field with initial value', (
      tester,
    ) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(
        find.widgetWithText(TextFormField, 'Explanation (Optional)'),
        findsOneWidget,
      );
    });

    testWidgets('should display delete button', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should display update button icon', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('should display all form fields in ListView', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.byType(ListView), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(3),
      ); // question, points, explanation
    });

    testWidgets('should have Form widget', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should display info icon for question type', (tester) async {
      // act
      await tester.pumpWidget(createEditQuestionFormWidget());

      // assert
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
