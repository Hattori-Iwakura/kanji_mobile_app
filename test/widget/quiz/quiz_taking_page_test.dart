import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/quiz_fixtures.dart';

class MockQuizBloc extends Mock implements QuizBloc {}

void main() {
  late MockQuizBloc mockBloc;

  setUp(() {
    mockBloc = MockQuizBloc();
  });

  Widget createQuizSessionWidget(QuizSessionActive state) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        ),
        body: BlocProvider<QuizBloc>.value(
          value: mockBloc,
          child: BlocBuilder<QuizBloc, QuizState>(
            builder: (context, state) {
              if (state is QuizSessionActive) {
                final question = state.currentQuestion;
                if (question == null) {
                  return const Center(
                    child: Text(
                      'No question',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress indicator
                      LinearProgressIndicator(
                        value: state.progressPercentage / 100,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.blue),
                      ),
                      const SizedBox(height: 16),

                      // Question count
                      Text(
                        'Question ${state.currentIndex + 1} of ${state.questions.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Question text
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    question.type,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${question.points} pts',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              question.questionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Answer section (simplified)
                      if (question.type == 'MULTIPLE_CHOICE') ...[
                        ...question.options.map(
                          (option) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                side: const BorderSide(color: Colors.white30),
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  group('QuizTakingPage UI', () {
    testWidgets('should display question number', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1, tQuestionTrueFalse1],
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.text('Question 1 of 2'), findsOneWidget);
    });

    testWidgets('should display question text', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1],
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.text('What does 日 mean?'), findsOneWidget);
    });

    testWidgets('should display question type badge', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1],
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.text('MULTIPLE_CHOICE'), findsOneWidget);
    });

    testWidgets('should display points for question', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1], // 10 points
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.text('10 pts'), findsOneWidget);
    });

    testWidgets('should display progress indicator', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1, tQuestionTrueFalse1],
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display multiple choice options', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1], // 4 options
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));
      await tester.pumpAndSettle();

      // assert - should have option buttons
      expect(find.text('sun'), findsOneWidget);
      expect(find.text('moon'), findsOneWidget);
      expect(find.text('fire'), findsOneWidget);
      expect(find.text('water'), findsOneWidget);
    });

    testWidgets('should update question number when at second question', (
      tester,
    ) async {
      // arrange - question 2 of 2
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1, tQuestionTrueFalse1],
        currentIndex: 1,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.text('Question 2 of 2'), findsOneWidget);
    });

    testWidgets('should display true/false question type', (tester) async {
      // arrange - TRUE_FALSE question
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionTrueFalse1],
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuizSessionWidget(state));

      // assert
      expect(find.text('TRUE_FALSE'), findsOneWidget);
    });
  });
}
