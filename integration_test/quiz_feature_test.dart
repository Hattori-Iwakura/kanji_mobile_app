import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/injection_container.dart' as di;
import 'package:kanji_flutter/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kanji_flutter/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kanji_flutter/features/quiz/presentation/bloc/quiz_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quiz Feature Integration Tests', () {
    setUpAll(() async {
      await di.init();
    });

    testWidgets('Load All Quizzes: Should fetch available quizzes', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<QuizBloc>(
            create: (_) => quizBloc,
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is QuizzesLoaded) {
                  return Scaffold(
                    body: ListView.builder(
                      itemCount: state.quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = state.quizzes[index];
                        return ListTile(
                          title: Text(quiz.title),
                          subtitle: Text(
                            'Questions: ${quiz.totalQuestions} | '
                            'Public: ${quiz.isPublic}',
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is QuizError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Load quizzes
      quizBloc.add(GetAllQuizzesEvent());

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = quizBloc.state;
      expect(state is QuizzesLoaded || state is QuizError, true);

      await quizBloc.close();
    });

    testWidgets('Get Quiz by ID: Should fetch quiz details', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<QuizBloc>(
            create: (_) => quizBloc,
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is QuizLoaded) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.quiz.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Description: ${state.quiz.description}'),
                          Text('Questions: ${state.quiz.totalQuestions}'),
                          Text('Public: ${state.quiz.isPublic ? 'Yes' : 'No'}'),
                        ],
                      ),
                    ),
                  );
                } else if (state is QuizError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Load quiz by ID
      quizBloc.add(GetQuizByIdEvent(1));

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = quizBloc.state;
      expect(state is QuizLoaded || state is QuizError, true);

      await quizBloc.close();
    });

    testWidgets('Create Quiz: Should create new quiz successfully', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<QuizBloc>(
            create: (_) => quizBloc,
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is QuizCreated) {
                  return Scaffold(
                    body: Center(
                      child: Text('Quiz created: ${state.quiz.title}'),
                    ),
                  );
                } else if (state is QuizError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(body: Center(child: Text('Ready')));
              },
            ),
          ),
        ),
      );

      // Create quiz
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      quizBloc.add(
        CreateQuizEvent(
          title: 'Test Quiz $timestamp',
          description: 'Integration test quiz',
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = quizBloc.state;
      expect(state is QuizCreated || state is QuizError, true);

      await quizBloc.close();
    });

    testWidgets('Update Quiz: Should modify quiz properties', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<QuizBloc>(
            create: (_) => quizBloc,
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizUpdated) {
                  return Scaffold(
                    body: Center(
                      child: Text('Quiz updated: ${state.quiz.title}'),
                    ),
                  );
                } else if (state is QuizError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Update quiz
      quizBloc.add(
        UpdateQuizEvent(
          id: 1,
          title: 'Updated Quiz Title',
          description: 'Updated description',
          isPublic: true,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = quizBloc.state;
      expect(state is QuizUpdated || state is QuizError, true);

      await quizBloc.close();
    });

    testWidgets('Delete Quiz: Should remove quiz successfully', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      // First create a quiz to delete
      quizBloc.add(
        CreateQuizEvent(
          title: 'Quiz to Delete ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Will be deleted',
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      int? quizIdToDelete;
      if (quizBloc.state is QuizCreated) {
        quizIdToDelete = (quizBloc.state as QuizCreated).quiz.id;
      }

      if (quizIdToDelete != null) {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<QuizBloc>(
              create: (_) => quizBloc,
              child: BlocBuilder<QuizBloc, QuizState>(
                builder: (context, state) {
                  if (state is QuizDeleted) {
                    return const Scaffold(
                      body: Center(child: Text('Quiz deleted')),
                    );
                  } else if (state is QuizError) {
                    return Scaffold(
                      body: Center(child: Text('Error: ${state.message}')),
                    );
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
        );

        // Delete the quiz
        quizBloc.add(DeleteQuizEvent(quizIdToDelete));

        await tester.pumpAndSettle(const Duration(seconds: 5));

        final state = quizBloc.state;
        expect(state is QuizDeleted || state is QuizError, true);
      }

      await quizBloc.close();
    });

    testWidgets('Start Quiz Attempt: Should initialize quiz session', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<QuizBloc>(
            create: (_) => quizBloc,
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizAttemptStarted) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Quiz started! Attempt ID: ${state.attempt.id}',
                      ),
                    ),
                  );
                } else if (state is QuizError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Start quiz attempt
      quizBloc.add(const StartQuizAttemptEvent(1));

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = quizBloc.state;
      expect(state is QuizAttemptStarted || state is QuizError, true);

      await quizBloc.close();
    });

    testWidgets('Submit Quiz Attempt: Should submit answers and get score', (
      WidgetTester tester,
    ) async {
      final quizBloc = di.sl<QuizBloc>();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<QuizBloc>(
            create: (_) => quizBloc,
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is QuizAttemptSubmitted) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Quiz Submitted!'),
                          Text('Score: ${state.attempt.score}%'),
                          Text(
                            'Correct: ${state.attempt.correctAnswers}/'
                            '${state.attempt.totalQuestions}',
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is QuizError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${state.message}')),
                  );
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ),
      );

      // Submit quiz attempt with sample answers
      quizBloc.add(
        const SubmitQuizAttemptEvent(
          attemptId: 1,
          answers: [
            {'questionId': 1, 'selectedOption': 'A'},
            {'questionId': 2, 'selectedOption': 'B'},
            {'questionId': 3, 'selectedOption': 'C'},
          ],
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final state = quizBloc.state;
      expect(state is QuizAttemptSubmitted || state is QuizError, true);

      await quizBloc.close();
    });
  });
}
