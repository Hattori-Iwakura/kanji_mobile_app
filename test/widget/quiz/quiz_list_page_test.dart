import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/widgets/quiz_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures/quiz_fixtures.dart';

class MockQuizBloc extends Mock implements QuizBloc {}

void main() {
  late MockQuizBloc mockBloc;

  setUp(() {
    mockBloc = MockQuizBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Quizzes', style: TextStyle(color: Colors.white)),
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

              if (state is QuizError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (state is QuizzesLoaded) {
                if (!state.hasQuizzes) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Quizzes Available',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = state.quizzes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: QuizCard(quiz: quiz, onTap: () {}),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  group('QuizListPage', () {
    testWidgets('should display loading indicator when state is QuizLoading', (
      tester,
    ) async {
      // arrange
      when(() => mockBloc.state).thenReturn(QuizLoading());
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display quiz list when state is QuizzesLoaded', (
      tester,
    ) async {
      // arrange
      when(() => mockBloc.state).thenReturn(QuizzesLoaded([tQuiz1, tQuiz2]));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(QuizCard), findsNWidgets(2));
      expect(find.text('JLPT N5 Practice Quiz'), findsOneWidget);
    });

    testWidgets('should display empty state when no quizzes available', (
      tester,
    ) async {
      // arrange
      when(() => mockBloc.state).thenReturn(const QuizzesLoaded([]));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('No Quizzes Available'), findsOneWidget);
      expect(find.byIcon(Icons.quiz), findsOneWidget);
    });

    testWidgets('should display error message when state is QuizError', (
      tester,
    ) async {
      // arrange
      const errorMessage = 'Failed to load quizzes';
      when(() => mockBloc.state).thenReturn(const QuizError(errorMessage));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should display app bar with title', (tester) async {
      // arrange
      when(() => mockBloc.state).thenReturn(QuizzesLoaded([tQuiz1]));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Quizzes'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display multiple quiz cards', (tester) async {
      // arrange
      when(
        () => mockBloc.state,
      ).thenReturn(QuizzesLoaded([tQuiz1, tQuiz2, tQuiz3]));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(QuizCard), findsNWidgets(3));
    });

    testWidgets('should display quiz details in cards', (tester) async {
      // arrange
      when(() => mockBloc.state).thenReturn(QuizzesLoaded([tQuiz1]));
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // assert
      expect(find.text('JLPT N5 Practice Quiz'), findsOneWidget);
      expect(find.text('Test your basic kanji knowledge'), findsOneWidget);
      expect(find.text('EASY'), findsOneWidget);
    });
  });
}
