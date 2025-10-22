import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kanji_mobile_v1/core/errors/failures.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/entities/quiz_result.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_all_quizzes.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_quiz_questions.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/submit_quiz_answer.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/complete_quiz.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_quiz_history.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_state.dart';

// Mock classes
class MockGetAllQuizzes extends Mock implements GetAllQuizzes {}

class MockGetQuizQuestions extends Mock implements GetQuizQuestions {}

class MockSubmitQuizAnswer extends Mock implements SubmitQuizAnswer {}

class MockCompleteQuiz extends Mock implements CompleteQuiz {}

class MockGetQuizHistory extends Mock implements GetQuizHistory {}

class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late QuizBloc bloc;
  late MockGetAllQuizzes mockGetAllQuizzes;
  late MockGetQuizQuestions mockGetQuizQuestions;
  late MockSubmitQuizAnswer mockSubmitQuizAnswer;
  late MockCompleteQuiz mockCompleteQuiz;
  late MockGetQuizHistory mockGetQuizHistory;
  late MockQuizRepository mockRepository;

  setUp(() {
    mockGetAllQuizzes = MockGetAllQuizzes();
    mockGetQuizQuestions = MockGetQuizQuestions();
    mockSubmitQuizAnswer = MockSubmitQuizAnswer();
    mockCompleteQuiz = MockCompleteQuiz();
    mockGetQuizHistory = MockGetQuizHistory();
    mockRepository = MockQuizRepository();

    bloc = QuizBloc(
      getAllQuizzes: mockGetAllQuizzes,
      getQuizQuestions: mockGetQuizQuestions,
      submitQuizAnswer: mockSubmitQuizAnswer,
      completeQuiz: mockCompleteQuiz,
      getQuizHistory: mockGetQuizHistory,
      repository: mockRepository,
    );
  });

  final testQuizzes = [
    Quiz(
      id: 'quiz-1',
      title: 'JLPT N5 Quiz',
      description: 'Basic kanji quiz',
      difficulty: 'EASY',
      totalQuestions: 10,
      timeLimit: 600,
      passingScore: 70,
      isPublished: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  final testQuestions = [
    Question(
      id: 'q1',
      quizId: 'quiz-1',
      type: 'MULTIPLE_CHOICE',
      questionText: 'What is 日?',
      options: ['にち', 'げつ', 'か', 'すい'],
      correctAnswer: 'にち',
      explanation: '日 is read as "にち"',
      points: 10,
      orderIndex: 0,
      createdAt: DateTime(2024, 1, 1),
    ),
    Question(
      id: 'q2',
      quizId: 'quiz-1',
      type: 'TRUE_FALSE',
      questionText: '月 means moon',
      options: ['True', 'False'],
      correctAnswer: 'True',
      points: 5,
      orderIndex: 1,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  final testResult = QuizResult(
    id: 'result-1',
    userId: 'user-1',
    quizId: 'quiz-1',
    totalQuestions: 2,
    correctAnswers: 2,
    incorrectAnswers: 0,
    skippedQuestions: 0,
    totalPoints: 15,
    earnedPoints: 15,
    scorePercentage: 100.0,
    timeSpent: 300,
    isPassed: true,
    answers: const [],
    completedAt: DateTime(2024, 1, 1, 12, 0),
    createdAt: DateTime(2024, 1, 1, 12, 0),
  );

  final testHistory = [testResult];

  group('QuizBloc', () {
    test('initial state is QuizInitial', () {
      expect(bloc.state, QuizInitial());
    });

    group('LoadQuizzesEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizzesLoaded] when loading succeeds',
        build: () {
          when(
            () => mockGetAllQuizzes(),
          ).thenAnswer((_) async => Right(testQuizzes));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadQuizzesEvent()),
        expect: () => [QuizLoading(), QuizzesLoaded(testQuizzes)],
        verify: (_) {
          verify(() => mockGetAllQuizzes()).called(1);
        },
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizzesLoaded] with empty list when no quizzes',
        build: () {
          when(
            () => mockGetAllQuizzes(),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadQuizzesEvent()),
        expect: () => [QuizLoading(), const QuizzesLoaded([])],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when loading fails',
        build: () {
          when(
            () => mockGetAllQuizzes(),
          ).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadQuizzesEvent()),
        expect: () => [QuizLoading(), const QuizError('Server error')],
      );
    });

    group('LoadQuizHistoryEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizHistoryLoaded] when loading succeeds',
        build: () {
          when(
            () => mockGetQuizHistory(),
          ).thenAnswer((_) async => Right(testHistory));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadQuizHistoryEvent()),
        expect: () => [QuizLoading(), QuizHistoryLoaded(testHistory)],
        verify: (_) {
          verify(() => mockGetQuizHistory()).called(1);
        },
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizHistoryLoaded] with empty list when no history',
        build: () {
          when(
            () => mockGetQuizHistory(),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadQuizHistoryEvent()),
        expect: () => [QuizLoading(), const QuizHistoryLoaded([])],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when loading fails',
        build: () {
          when(() => mockGetQuizHistory()).thenAnswer(
            (_) async => const Left(ServerFailure('Failed to get history')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(LoadQuizHistoryEvent()),
        expect: () => [QuizLoading(), const QuizError('Failed to get history')],
      );
    });

    group('StartQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizSessionActive] when quiz starts successfully',
        build: () {
          when(
            () => mockRepository.startQuiz('quiz-1'),
          ).thenAnswer((_) async => const Right('session-1'));
          when(
            () => mockGetQuizQuestions('quiz-1'),
          ).thenAnswer((_) async => Right(testQuestions));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent('quiz-1')),
        expect: () => [
          QuizLoading(),
          isA<QuizSessionActive>()
              .having((s) => s.quizId, 'quizId', 'quiz-1')
              .having((s) => s.questions.length, 'questions length', 2)
              .having((s) => s.currentIndex, 'currentIndex', 0)
              .having((s) => s.userAnswers, 'userAnswers', {}),
        ],
        verify: (_) {
          verify(() => mockRepository.startQuiz('quiz-1')).called(1);
          verify(() => mockGetQuizQuestions('quiz-1')).called(1);
        },
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when starting quiz fails',
        build: () {
          when(() => mockRepository.startQuiz('quiz-1')).thenAnswer(
            (_) async => const Left(ServerFailure('Failed to start quiz')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent('quiz-1')),
        expect: () => [QuizLoading(), const QuizError('Failed to start quiz')],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when no questions found',
        build: () {
          when(
            () => mockRepository.startQuiz('quiz-1'),
          ).thenAnswer((_) async => const Right('session-1'));
          when(
            () => mockGetQuizQuestions('quiz-1'),
          ).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent('quiz-1')),
        expect: () => [
          QuizLoading(),
          const QuizError('No questions found for this quiz'),
        ],
      );
    });

    group('AnswerQuestionEvent', () {
      final activeState = QuizSessionActive(
        quizId: 'quiz-1',
        questions: testQuestions,
        currentIndex: 0,
        userAnswers: {},
        answerResults: {},
        startTime: DateTime(2024, 1, 1, 12, 0),
      );

      blocTest<QuizBloc, QuizState>(
        'emits updated state with correct answer',
        build: () {
          when(
            () => mockSubmitQuizAnswer(
              quizId: 'quiz-1',
              questionId: 'q1',
              answer: 'にち',
            ),
          ).thenAnswer((_) async => const Right(true));
          return bloc;
        },
        seed: () => activeState,
        act: (bloc) =>
            bloc.add(const AnswerQuestionEvent(questionId: 'q1', answer: 'にち')),
        expect: () => [
          isA<QuizSessionActive>()
              .having((s) => s.userAnswers['q1'], 'answer', 'にち')
              .having((s) => s.answerResults['q1'], 'isCorrect', true),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'emits updated state with incorrect answer',
        build: () {
          when(
            () => mockSubmitQuizAnswer(
              quizId: 'quiz-1',
              questionId: 'q1',
              answer: 'げつ',
            ),
          ).thenAnswer((_) async => const Right(false));
          return bloc;
        },
        seed: () => activeState,
        act: (bloc) =>
            bloc.add(const AnswerQuestionEvent(questionId: 'q1', answer: 'げつ')),
        expect: () => [
          isA<QuizSessionActive>()
              .having((s) => s.userAnswers['q1'], 'answer', 'げつ')
              .having((s) => s.answerResults['q1'], 'isCorrect', false),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'emits QuizError when submission fails',
        build: () {
          when(
            () => mockSubmitQuizAnswer(
              quizId: 'quiz-1',
              questionId: 'q1',
              answer: 'にち',
            ),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Submission failed')),
          );
          return bloc;
        },
        seed: () => activeState,
        act: (bloc) =>
            bloc.add(const AnswerQuestionEvent(questionId: 'q1', answer: 'にち')),
        expect: () => [const QuizError('Submission failed')],
      );

      blocTest<QuizBloc, QuizState>(
        'does nothing when not in session',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const AnswerQuestionEvent(questionId: 'q1', answer: 'にち')),
        expect: () => [],
      );
    });

    group('NextQuestionEvent', () {
      final activeState = QuizSessionActive(
        quizId: 'quiz-1',
        questions: testQuestions,
        currentIndex: 0,
        userAnswers: {'q1': 'にち'},
        answerResults: {'q1': true},
        startTime: DateTime(2024, 1, 1, 12, 0),
      );

      blocTest<QuizBloc, QuizState>(
        'moves to next question when not on last',
        build: () => bloc,
        seed: () => activeState,
        act: (bloc) => bloc.add(NextQuestionEvent()),
        expect: () => [
          isA<QuizSessionActive>().having(
            (s) => s.currentIndex,
            'currentIndex',
            1,
          ),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'does nothing when on last question',
        build: () => bloc,
        seed: () => activeState.copyWith(currentIndex: 1),
        act: (bloc) => bloc.add(NextQuestionEvent()),
        expect: () => [],
      );
    });

    group('PreviousQuestionEvent', () {
      final activeState = QuizSessionActive(
        quizId: 'quiz-1',
        questions: testQuestions,
        currentIndex: 1,
        userAnswers: {},
        answerResults: {},
        startTime: DateTime(2024, 1, 1, 12, 0),
      );

      blocTest<QuizBloc, QuizState>(
        'moves to previous question when not on first',
        build: () => bloc,
        seed: () => activeState,
        act: (bloc) => bloc.add(PreviousQuestionEvent()),
        expect: () => [
          isA<QuizSessionActive>().having(
            (s) => s.currentIndex,
            'currentIndex',
            0,
          ),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'does nothing when on first question',
        build: () => bloc,
        seed: () => activeState.copyWith(currentIndex: 0),
        act: (bloc) => bloc.add(PreviousQuestionEvent()),
        expect: () => [],
      );
    });

    group('CompleteQuizEvent', () {
      final activeState = QuizSessionActive(
        quizId: 'quiz-1',
        questions: testQuestions,
        currentIndex: 1,
        userAnswers: {'q1': 'にち', 'q2': 'True'},
        answerResults: {'q1': true, 'q2': true},
        startTime: DateTime(2024, 1, 1, 12, 0),
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizCompleted] when completion succeeds',
        build: () {
          when(
            () => mockCompleteQuiz(quizId: 'quiz-1', timeSpent: 300),
          ).thenAnswer((_) async => Right(testResult));
          return bloc;
        },
        seed: () => activeState,
        act: (bloc) => bloc.add(const CompleteQuizEvent(300)),
        expect: () => [QuizLoading(), QuizCompleted(testResult)],
        verify: (_) {
          verify(
            () => mockCompleteQuiz(quizId: 'quiz-1', timeSpent: 300),
          ).called(1);
        },
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when completion fails',
        build: () {
          when(
            () => mockCompleteQuiz(quizId: 'quiz-1', timeSpent: 300),
          ).thenAnswer(
            (_) async => const Left(ServerFailure('Failed to complete')),
          );
          return bloc;
        },
        seed: () => activeState,
        act: (bloc) => bloc.add(const CompleteQuizEvent(300)),
        expect: () => [QuizLoading(), const QuizError('Failed to complete')],
      );
    });
  });
}
