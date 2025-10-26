import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:kanji_mobile_v1/core/constants/api_endpoints.dart';
import 'package:kanji_mobile_v1/core/network/dio_client.dart';
import 'package:kanji_mobile_v1/features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/add_question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/complete_quiz.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/delete_question.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_all_quizzes.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_quiz_history.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/get_quiz_questions.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/submit_quiz_answer.dart';
import 'package:kanji_mobile_v1/features/quiz/domain/usecases/update_question.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kanji_mobile_v1/features/quiz/presentation/bloc/quiz_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../helpers/fixtures/quiz_fixtures.dart';

// Mock classes for DioClient dependencies
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLogger extends Mock implements Logger {}

void main() {
  late QuizBloc bloc;
  late Dio dio;
  late DioAdapter dioAdapter;
  late QuizRepositoryImpl repository;

  setUpAll(() {
    ApiEndpoints.baseUrl = 'http://localhost:3000/api/v1';
  });

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;

    // Create DioClient with mocked dependencies
    final mockStorage = MockSecureStorage();
    final mockLogger = MockLogger();

    // Stub secure storage methods
    when(
      () => mockStorage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);
    when(
      () => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async => {});
    when(
      () => mockStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async => {});

    final dioClient = DioClient(mockStorage, mockLogger);
    // Replace the internal dio with our mocked one
    dioClient.dio.httpClientAdapter = dioAdapter;

    final dataSource = QuizRemoteDataSource(dioClient);
    repository = QuizRepositoryImpl(dataSource);

    bloc = QuizBloc(
      getAllQuizzes: GetAllQuizzes(repository),
      getQuizQuestions: GetQuizQuestions(repository),
      submitQuizAnswer: SubmitQuizAnswer(repository),
      completeQuiz: CompleteQuiz(repository),
      getQuizHistory: GetQuizHistory(repository),
      addQuestion: AddQuestion(repository),
      updateQuestion: UpdateQuestion(repository),
      deleteQuestion: DeleteQuestion(repository),
      repository: repository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadQuizzesEvent Integration', () {
    test(
      'should emit [Loading, QuizzesLoaded] when fetching quizzes successfully',
      () async {
        // arrange
        dioAdapter.onGet(
          'http://localhost:3000/api/v1/quizzes',
          (server) => server.reply(200, [tQuiz1Json, tQuiz2Json]),
        );

        // assert later
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<QuizLoading>(),
            isA<QuizzesLoaded>().having(
              (s) => s.quizzes.length,
              'quiz count',
              2,
            ),
          ]),
        );

        // act
        bloc.add(LoadQuizzesEvent());
      },
    );

    test('should emit [Loading, Error] when API fails', () async {
      // arrange
      dioAdapter.onGet(
        'http://localhost:3000/api/v1/quizzes',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      // assert later
      expectLater(
        bloc.stream,
        emitsInOrder([isA<QuizLoading>(), isA<QuizError>()]),
      );

      // act
      bloc.add(LoadQuizzesEvent());
    });
  });

  group('LoadQuizHistoryEvent Integration', () {
    test(
      'should emit [Loading, QuizHistoryLoaded] when fetching history successfully',
      () async {
        // arrange
        dioAdapter.onGet(
          'http://localhost:3000/api/v1/quizzes/history',
          (server) => server.reply(200, [tQuizResult1Json, tQuizResult2Json]),
        );

        // assert later
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<QuizLoading>(),
            isA<QuizHistoryLoaded>().having(
              (s) => s.history.length,
              'history count',
              2,
            ),
          ]),
        );

        // act
        bloc.add(LoadQuizHistoryEvent());
      },
    );
  });

  group('Quiz Session Flow Integration', () {
    const tQuizId = 'quiz-1';
    const tSessionId = 'session-123';
    const baseUrl = 'http://localhost:3000/api/v1';

    test('should start quiz session and load questions', () async {
      // arrange - start quiz
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/start',
        (server) => server.reply(200, {'sessionId': tSessionId}),
      );

      // arrange - load questions
      dioAdapter.onGet(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(200, [
          tQuestionMultipleChoice1Json,
          tQuestionTrueFalse1Json,
        ]),
      );

      // assert later
      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<QuizLoading>(),
          isA<QuizSessionActive>().having(
            (s) => s.questions.length,
            'questions count',
            2,
          ),
        ]),
      );

      // act
      bloc.add(const StartQuizEvent(tQuizId));
    });

    test('should handle answer submission flow', () async {
      // arrange - start quiz first
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/start',
        (server) => server.reply(200, {'sessionId': tSessionId}),
      );

      dioAdapter.onGet(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(200, [tQuestionMultipleChoice1Json]),
      );

      // arrange - submit answer
      const tQuestionId = 'q-1';
      const tAnswer = 'sun';
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/answer',
        (server) => server.reply(200, {'isCorrect': true}),
        data: {'questionId': tQuestionId, 'answer': tAnswer},
      );

      // act - start quiz
      bloc.add(const StartQuizEvent(tQuizId));

      await Future.delayed(const Duration(milliseconds: 100));

      // act - answer question
      bloc.add(
        const AnswerQuestionEvent(questionId: tQuestionId, answer: tAnswer),
      );

      // assert - should have answer in session
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizSessionActive>().having(
            (s) => s.userAnswers[tQuestionId],
            'user answer',
            tAnswer,
          ),
        ),
      );
    });

    test('should navigate between questions', () async {
      // arrange - start quiz with multiple questions
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/start',
        (server) => server.reply(200, {'sessionId': tSessionId}),
      );

      dioAdapter.onGet(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(200, [
          tQuestionMultipleChoice1Json,
          tQuestionTrueFalse1Json,
          tQuestionFillInBlank1Json,
        ]),
      );

      // act - start quiz
      bloc.add(const StartQuizEvent(tQuizId));

      await Future.delayed(const Duration(milliseconds: 100));

      // act - next question
      bloc.add(NextQuestionEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizSessionActive>().having(
            (s) => s.currentIndex,
            'current index',
            1,
          ),
        ),
      );

      // act - previous question
      bloc.add(PreviousQuestionEvent());

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizSessionActive>().having(
            (s) => s.currentIndex,
            'current index',
            0,
          ),
        ),
      );
    });

    test('should complete quiz and get result', () async {
      // arrange - start quiz
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/start',
        (server) => server.reply(200, {'sessionId': tSessionId}),
      );

      dioAdapter.onGet(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(200, [tQuestionMultipleChoice1Json]),
      );

      // arrange - complete quiz
      const tTimeSpent = 120;
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/complete',
        (server) => server.reply(200, tQuizResult1Json),
        data: {'timeSpent': tTimeSpent},
      );

      // act - start quiz
      bloc.add(const StartQuizEvent(tQuizId));

      await Future.delayed(const Duration(milliseconds: 100));

      // act - complete quiz
      bloc.add(const CompleteQuizEvent(tTimeSpent));

      // assert
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizCompleted>().having(
            (s) => s.result.quizId,
            'quiz id',
            tQuizId,
          ),
        ),
      );
    });
  });

  group('Question Management Flow Integration', () {
    const tQuizId = 'quiz-1';
    const baseUrl = 'http://localhost:3000/api/v1';

    test('should add question to quiz', () async {
      // arrange
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(200, tQuestionMultipleChoice1Json),
        data: {
          'type': 'MULTIPLE_CHOICE',
          'questionText': 'What is this kanji?',
          'options': ['sun', 'moon'],
          'correctAnswer': 'sun',
          'points': 10,
          'meanings': [],
        },
      );

      // act
      bloc.add(
        const AddQuestionEvent(
          quizId: tQuizId,
          type: 'MULTIPLE_CHOICE',
          questionText: 'What is this kanji?',
          options: ['sun', 'moon'],
          correctAnswer: 'sun',
          points: 10,
        ),
      );

      // assert - should reload questions after adding
      await expectLater(bloc.stream, emits(isA<QuizLoading>()));
    });

    test('should update question', () async {
      // arrange
      const tQuestionId = 'q-1';
      dioAdapter.onPut(
        '$baseUrl/quizzes/$tQuizId/questions/$tQuestionId',
        (server) => server.reply(200, tQuestionMultipleChoice1Json),
        data: {'questionText': 'Updated question', 'points': 15},
      );

      // act
      bloc.add(
        const UpdateQuestionEvent(
          quizId: tQuizId,
          questionId: tQuestionId,
          questionText: 'Updated question',
          points: 15,
        ),
      );

      // assert
      await expectLater(bloc.stream, emits(isA<QuizLoading>()));
    });

    test('should delete question', () async {
      // arrange
      const tQuestionId = 'q-1';
      dioAdapter.onDelete(
        '$baseUrl/quizzes/$tQuizId/questions/$tQuestionId',
        (server) => server.reply(200, {}),
      );

      // act
      bloc.add(
        const DeleteQuestionEvent(quizId: tQuizId, questionId: tQuestionId),
      );

      // assert
      await expectLater(bloc.stream, emits(isA<QuizLoading>()));
    });

    test('should handle question management error', () async {
      // arrange
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(400, {'message': 'Invalid question data'}),
      );

      // act
      bloc.add(
        const AddQuestionEvent(
          quizId: tQuizId,
          type: 'INVALID_TYPE',
          questionText: '',
          options: [],
          correctAnswer: '',
        ),
      );

      // assert
      await expectLater(bloc.stream, emitsThrough(isA<QuizError>()));
    });
  });

  group('Quiz State Helpers Integration', () {
    const baseUrl = 'http://localhost:3000/api/v1';

    test('QuizzesLoaded should have helper methods', () async {
      // arrange
      dioAdapter.onGet(
        '$baseUrl/quizzes',
        (server) => server.reply(200, [tQuiz1Json, tQuiz2Json]),
      );

      // act
      bloc.add(LoadQuizzesEvent());

      // assert
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizzesLoaded>()
              .having((s) => s.hasQuizzes, 'has quizzes', true)
              .having(
                (s) => s.getByDifficulty('EASY').length,
                'easy quizzes',
                greaterThanOrEqualTo(0),
              ),
        ),
      );
    });

    test('QuizHistoryLoaded should calculate statistics', () async {
      // arrange
      dioAdapter.onGet(
        '$baseUrl/quizzes/history',
        (server) => server.reply(200, [tQuizResult1Json, tQuizResult2Json]),
      );

      // act
      bloc.add(LoadQuizHistoryEvent());

      // assert
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizHistoryLoaded>()
              .having((s) => s.hasHistory, 'has history', true)
              .having((s) => s.totalCompleted, 'total completed', 2)
              .having((s) => s.averageScore, 'average score', greaterThan(0.0)),
        ),
      );
    });

    test('QuizSessionActive should track progress', () async {
      // arrange
      const tQuizId = 'quiz-1';
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/start',
        (server) => server.reply(200, {'sessionId': 'session-123'}),
      );

      dioAdapter.onGet(
        '$baseUrl/quizzes/$tQuizId/questions',
        (server) => server.reply(200, [
          tQuestionMultipleChoice1Json,
          tQuestionTrueFalse1Json,
        ]),
      );

      // act
      bloc.add(const StartQuizEvent(tQuizId));

      // assert
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<QuizSessionActive>()
              .having((s) => s.currentQuestion, 'current question', isNotNull)
              .having((s) => s.isFirstQuestion, 'is first', true)
              .having((s) => s.isLastQuestion, 'is last', false)
              .having((s) => s.progressPercentage, 'progress', 0.0),
        ),
      );
    });
  });

  group('Error Handling Integration', () {
    const baseUrl = 'http://localhost:3000/api/v1';

    test('should handle network timeout', () async {
      // arrange
      dioAdapter.onGet(
        '$baseUrl/quizzes',
        (server) => server.throws(
          404,
          DioException(
            requestOptions: RequestOptions(path: '/quizzes'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
      );

      // assert later
      expectLater(
        bloc.stream,
        emitsInOrder([isA<QuizLoading>(), isA<QuizError>()]),
      );

      // act
      bloc.add(LoadQuizzesEvent());
    });

    test('should handle unauthorized access', () async {
      // arrange
      dioAdapter.onGet(
        '$baseUrl/quizzes',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      // assert later
      expectLater(
        bloc.stream,
        emitsInOrder([isA<QuizLoading>(), isA<QuizError>()]),
      );

      // act
      bloc.add(LoadQuizzesEvent());
    });

    test('should handle quiz not found', () async {
      // arrange
      const tQuizId = 'non-existent';
      dioAdapter.onPost(
        '$baseUrl/quizzes/$tQuizId/start',
        (server) => server.reply(404, {'message': 'Quiz not found'}),
      );

      // assert later
      expectLater(
        bloc.stream,
        emitsInOrder([isA<QuizLoading>(), isA<QuizError>()]),
      );

      // act
      bloc.add(const StartQuizEvent(tQuizId));
    });
  });
}
