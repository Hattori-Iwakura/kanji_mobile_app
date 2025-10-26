import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_v1/core/constants/api_endpoints.dart';
import 'package:kanji_mobile_v1/core/network/dio_client.dart';
import 'package:kanji_mobile_v1/features/quiz/data/datasources/quiz_remote_datasource.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/question_model.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_model.dart';
import 'package:kanji_mobile_v1/features/quiz/data/models/quiz_result_model.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/fixtures/quiz_fixtures.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late QuizRemoteDataSource dataSource;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUpAll(() {
    ApiEndpoints.baseUrl = 'http://localhost:3000/api/v1';
  });

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    dataSource = QuizRemoteDataSource(mockDioClient);
    when(() => mockDioClient.dio).thenReturn(mockDio);
  });

  group('getAllQuizzes', () {
    test('should perform GET request on /quizzes endpoint', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [tQuizJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes'),
        ),
      );

      // Act
      await dataSource.getAllQuizzes();

      // Assert
      verify(() => mockDio.get(any())).called(1);
    });

    test('should return list of QuizModel when successful', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [tQuizJson, tQuizJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes'),
        ),
      );

      // Act
      final result = await dataSource.getAllQuizzes();

      // Assert
      expect(result, isA<List<QuizModel>>());
      expect(result.length, 2);
    });
  });

  group('getQuizById', () {
    const tQuizId = '1';

    test('should perform GET request on /quizzes/:id endpoint', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tQuizJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId'),
        ),
      );

      // Act
      await dataSource.getQuizById(tQuizId);

      // Assert
      verify(() => mockDio.get(any())).called(1);
    });

    test('should return QuizModel when successful', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tQuizJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId'),
        ),
      );

      // Act
      final result = await dataSource.getQuizById(tQuizId);

      // Assert
      expect(result, isA<QuizModel>());
      expect(result.id, tQuizId);
    });
  });

  group('getQuizQuestions', () {
    const tQuizId = '1';

    test('should perform GET request on /quizzes/:id/questions', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [tQuestionMultipleChoiceJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/questions'),
        ),
      );

      // Act
      await dataSource.getQuizQuestions(tQuizId);

      // Assert
      verify(() => mockDio.get(any())).called(1);
    });

    test('should return list of QuestionModel', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [tQuestionMultipleChoiceJson, tQuestionDrawingJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/questions'),
        ),
      );

      // Act
      final result = await dataSource.getQuizQuestions(tQuizId);

      // Assert
      expect(result, isA<List<QuestionModel>>());
      expect(result.length, 2);
      expect(result.first.type, 'MULTIPLE_CHOICE');
      expect(result.last.type, 'DRAWING');
    });
  });

  group('submitAnswer', () {
    const tQuizId = '1';
    const tQuestionId = 'q-1';
    const tAnswer = 'sun';

    test('should perform POST request with answer data', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'isCorrect': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/answer'),
        ),
      );

      // Act
      await dataSource.submitAnswer(
        quizId: tQuizId,
        questionId: tQuestionId,
        answer: tAnswer,
      );

      // Assert
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('should return true for correct answer', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'isCorrect': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/answer'),
        ),
      );

      // Act
      final result = await dataSource.submitAnswer(
        quizId: tQuizId,
        questionId: tQuestionId,
        answer: tAnswer,
      );

      // Assert
      expect(result, true);
    });

    test('should return false for incorrect answer', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'isCorrect': false},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/answer'),
        ),
      );

      // Act
      final result = await dataSource.submitAnswer(
        quizId: tQuizId,
        questionId: tQuestionId,
        answer: 'wrong',
      );

      // Assert
      expect(result, false);
    });
  });

  group('completeQuiz', () {
    const tQuizId = '1';
    const tTimeSpent = 480;

    test('should perform POST request with time spent', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tQuizResultJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/complete'),
        ),
      );

      // Act
      await dataSource.completeQuiz(quizId: tQuizId, timeSpent: tTimeSpent);

      // Assert
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('should return QuizResultModel', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tQuizResultJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/complete'),
        ),
      );

      // Act
      final result = await dataSource.completeQuiz(
        quizId: tQuizId,
        timeSpent: tTimeSpent,
      );

      // Assert
      expect(result, isA<QuizResultModel>());
      expect(result.timeSpent, tTimeSpent);
    });
  });

  group('getQuizHistory', () {
    test('should perform GET request on /quiz-history endpoint', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [tQuizResultJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quiz-history'),
        ),
      );

      // Act
      await dataSource.getQuizHistory();

      // Assert
      verify(() => mockDio.get(any())).called(1);
    });

    test('should return list of QuizResultModel', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: [tQuizResultJson, tQuizResultJson],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/quiz-history'),
        ),
      );

      // Act
      final result = await dataSource.getQuizHistory();

      // Assert
      expect(result, isA<List<QuizResultModel>>());
      expect(result.length, 2);
    });
  });

  group('addQuestion', () {
    const tQuizId = 'quiz-1';

    test('should perform POST request with question data', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tQuestionMultipleChoiceJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/questions'),
        ),
      );

      // Act
      await dataSource.addQuestion(
        quizId: tQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'Test question',
        options: ['A', 'B', 'C'],
        correctAnswer: 'A',
        points: 10,
      );

      // Assert
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('should return QuestionModel', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tQuestionMultipleChoiceJson,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/quizzes/$tQuizId/questions'),
        ),
      );

      // Act
      final result = await dataSource.addQuestion(
        quizId: tQuizId,
        type: 'MULTIPLE_CHOICE',
        questionText: 'Test question',
        options: ['A', 'B'],
        correctAnswer: 'A',
      );

      // Assert
      expect(result, isA<QuestionModel>());
    });
  });

  group('updateQuestion', () {
    const tQuizId = 'quiz-1';
    const tQuestionId = 'q-1';

    test('should perform PUT request with update data', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tQuestionMultipleChoiceJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/quizzes/$tQuizId/questions/$tQuestionId',
          ),
        ),
      );

      // Act
      await dataSource.updateQuestion(
        quizId: tQuizId,
        questionId: tQuestionId,
        questionText: 'Updated question',
        points: 15,
      );

      // Assert
      verify(() => mockDio.put(any(), data: any(named: 'data'))).called(1);
    });

    test('should return updated QuestionModel', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tQuestionMultipleChoiceJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/quizzes/$tQuizId/questions/$tQuestionId',
          ),
        ),
      );

      // Act
      final result = await dataSource.updateQuestion(
        quizId: tQuizId,
        questionId: tQuestionId,
        questionText: 'Updated',
      );

      // Assert
      expect(result, isA<QuestionModel>());
    });
  });

  group('deleteQuestion', () {
    const tQuizId = 'quiz-1';
    const tQuestionId = 'q-1';

    test('should perform DELETE request', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 204,
          requestOptions: RequestOptions(
            path: '/quizzes/$tQuizId/questions/$tQuestionId',
          ),
        ),
      );

      // Act
      await dataSource.deleteQuestion(quizId: tQuizId, questionId: tQuestionId);

      // Assert
      verify(() => mockDio.delete(any())).called(1);
    });
  });
}
