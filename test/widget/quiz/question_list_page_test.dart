import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Widget createQuestionListWidget(QuizState state) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JLPT N5 Practice',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Questions',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        body: BlocProvider<QuizBloc>.value(
          value: mockBloc,
          child: BlocBuilder<QuizBloc, QuizState>(
            builder: (context, state) {
              if (state is QuizLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is QuizSessionActive) {
                final questions = state.questions;

                if (questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No questions yet',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      color: const Color(0xFF1A1A1A),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        title: Text(
                          question.questionText,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                question.type,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${question.points} pts',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                );
              }

              if (state is QuizError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  group('QuestionListPage UI', () {
    testWidgets('should display loading indicator', (tester) async {
      // arrange
      when(() => mockBloc.state).thenReturn(QuizLoading());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuestionListWidget(QuizLoading()));

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display quiz title and "Questions" subtitle', (
      tester,
    ) async {
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
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.text('JLPT N5 Practice'), findsOneWidget);
      expect(find.text('Questions'), findsOneWidget);
    });

    testWidgets('should display empty state when no questions', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [],
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.text('No questions yet'), findsOneWidget);
      expect(find.byIcon(Icons.quiz_outlined), findsOneWidget);
    });

    testWidgets('should display list of questions', (tester) async {
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
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
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
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.text('What does 日 mean?'), findsOneWidget);
    });

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
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
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
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.text('MULTIPLE_CHOICE'), findsOneWidget);
    });

    testWidgets('should display question points', (tester) async {
      // arrange
      final state = QuizSessionActive(
        quizId: 'quiz-1',
        questions: [tQuestionMultipleChoice1], // 10 pts
        currentIndex: 0,
        userAnswers: const {},
        answerResults: const {},
        startTime: DateTime.now(),
      );
      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuestionListWidget(state));

      // assert
      expect(find.text('10 pts'), findsOneWidget);
    });

    testWidgets('should display error message when error occurs', (
      tester,
    ) async {
      // arrange
      const errorState = QuizError('Failed to load questions');
      when(() => mockBloc.state).thenReturn(errorState);
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createQuestionListWidget(errorState));

      // assert
      expect(find.text('Failed to load questions'), findsOneWidget);
    });
  });
}
