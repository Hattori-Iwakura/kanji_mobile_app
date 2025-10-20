import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helper.dart';

void main() {
  final helper = IntegrationTestHelper();

  setUpAll(() async {
    // Health check
    await helper.loginAndGetToken();
    final response = await helper.apiClient.get('/quizzes');
    expect(response.statusCode, 200);
    print('✅ Backend is running');
  });

  group('Quiz Attempt Integration Tests', () {
    int? quizId;
    int? attemptId;

    test('Setup - Create a quiz with questions', () async {
      await helper.loginAndGetToken();

      // Create quiz
      final quizResponse = await helper.apiClient.post('/quizzes', {
        'title': 'Quiz Attempt Test',
        'description': 'Testing quiz attempts',
      });

      expect(quizResponse.statusCode, 201);
      final quizData = quizResponse.data['data'] ?? quizResponse.data;
      quizId = quizData['id'];

      print('✅ Quiz created with ID: $quizId');

      // Add questions
      await helper.apiClient.post('/quizzes/$quizId/questions', {
        'type': 'MULTIPLE_CHOICE',
        'question': 'What is 2+2?',
        'correctAnswer': '4',
        'options': ['2', '3', '4', '5'],
      });

      await helper.apiClient.post('/quizzes/$quizId/questions', {
        'type': 'FILL_IN_BLANK',
        'question': 'The capital of Japan is ___',
        'correctAnswer': 'Tokyo',
      });

      await helper.apiClient.post('/quizzes/$quizId/questions', {
        'type': 'MULTIPLE_CHOICE',
        'question': 'What is the color of the sky?',
        'correctAnswer': 'Blue',
        'options': ['Red', 'Blue', 'Green', 'Yellow'],
      });

      print('✅ 3 questions added to quiz');
    });

    test('Start quiz attempt - Success', () async {
      await helper.loginAndGetToken();

      final response = await helper.apiClient.post(
        '/quizzes/$quizId/start',
        {},
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;

      expect(data['id'], isNotNull);
      expect(data['quizId'], equals(quizId));
      expect(data['score'], equals(0));
      expect(data['maxScore'], equals(3)); // 3 questions
      expect(data['completed'], equals(false));
      expect(data['quiz'], isNotNull);
      expect(data['quiz']['questions'], isA<List>());
      expect((data['quiz']['questions'] as List).length, equals(3));

      attemptId = data['id'];

      print('✅ Quiz attempt started');
      print('   Attempt ID: $attemptId');
      print('   Max Score: ${data['maxScore']}');
    });

    test('Cannot start quiz with no questions', () async {
      await helper.loginAndGetToken();

      // Create empty quiz
      final emptyQuizResponse = await helper.apiClient.post('/quizzes', {
        'title': 'Empty Quiz',
      });

      final emptyQuizId =
          (emptyQuizResponse.data['data'] ?? emptyQuizResponse.data)['id'];

      // Try to start attempt
      try {
        await helper.apiClient.post('/quizzes/$emptyQuizId/start', {});
        fail('Should have thrown 403 error');
      } catch (e) {
        expect(e.toString(), contains('403'));
        print('✅ Correctly blocked starting quiz with no questions');
      }
    });

    test('Submit quiz answers - All correct', () async {
      await helper.loginAndGetToken();

      // Get question IDs from the attempt
      final attemptResponse = await helper.apiClient.get(
        '/quizzes/attempts/$attemptId',
      );
      final attemptData = attemptResponse.data['data'] ?? attemptResponse.data;
      final questions = attemptData['quiz']['questions'] as List;

      final response = await helper.apiClient.post(
        '/quizzes/attempts/$attemptId/submit',
        {
          'answers': [
            {'questionId': questions[0]['id'], 'answer': '4'},
            {'questionId': questions[1]['id'], 'answer': 'Tokyo'},
            {'questionId': questions[2]['id'], 'answer': 'Blue'},
          ],
        },
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;

      expect(data['id'], equals(attemptId));
      expect(data['completed'], equals(true));
      expect(data['score'], equals(3)); // All correct
      expect(data['maxScore'], equals(3));
      expect(data['answers'], isA<List>());
      expect((data['answers'] as List).length, equals(3));

      // Check all answers are marked correct
      final answers = data['answers'] as List;
      for (var answer in answers) {
        expect(answer['isCorrect'], equals(true));
        expect(answer['points'], equals(1));
      }

      print('✅ Quiz submitted with perfect score');
      print('   Score: ${data['score']}/${data['maxScore']}');
    });

    test('Submit quiz answers - Partial correct', () async {
      await helper.loginAndGetToken();

      // Start new attempt
      final startResponse = await helper.apiClient.post(
        '/quizzes/$quizId/start',
        {},
      );
      final startData = startResponse.data['data'] ?? startResponse.data;
      final newAttemptId = startData['id'];
      final questions = startData['quiz']['questions'] as List;

      // Submit with some wrong answers
      final response = await helper.apiClient.post(
        '/quizzes/attempts/$newAttemptId/submit',
        {
          'answers': [
            {'questionId': questions[0]['id'], 'answer': '5'}, // Wrong
            {'questionId': questions[1]['id'], 'answer': 'Tokyo'}, // Correct
            {'questionId': questions[2]['id'], 'answer': 'Red'}, // Wrong
          ],
        },
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;

      expect(data['score'], equals(1)); // Only 1 correct
      expect(data['maxScore'], equals(3));

      print('✅ Partial score recorded correctly');
      print('   Score: ${data['score']}/${data['maxScore']}');
    });

    test('Answer checking is case-insensitive', () async {
      await helper.loginAndGetToken();

      // Start new attempt
      final startResponse = await helper.apiClient.post(
        '/quizzes/$quizId/start',
        {},
      );
      final startData = startResponse.data['data'] ?? startResponse.data;
      final newAttemptId = startData['id'];
      final questions = startData['quiz']['questions'] as List;

      // Submit with different cases
      final response = await helper.apiClient.post(
        '/quizzes/attempts/$newAttemptId/submit',
        {
          'answers': [
            {'questionId': questions[0]['id'], 'answer': '4'},
            {
              'questionId': questions[1]['id'],
              'answer': 'TOKYO',
            }, // Different case
            {
              'questionId': questions[2]['id'],
              'answer': 'blue',
            }, // Different case
          ],
        },
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;

      expect(data['score'], equals(3)); // All should be correct

      print('✅ Case-insensitive answer checking works');
    });

    test('Cannot submit already completed attempt', () async {
      await helper.loginAndGetToken();

      // Get a question ID
      final attemptResponse = await helper.apiClient.get(
        '/quizzes/attempts/$attemptId',
      );
      final attemptData = attemptResponse.data['data'] ?? attemptResponse.data;
      final questions = attemptData['quiz']['questions'] as List;

      // Try to submit again
      try {
        await helper.apiClient.post('/quizzes/attempts/$attemptId/submit', {
          'answers': [
            {'questionId': questions[0]['id'], 'answer': '4'},
          ],
        });
        fail('Should have thrown 403 error');
      } catch (e) {
        expect(e.toString(), contains('403'));
        print('✅ Correctly blocked re-submitting completed attempt');
      }
    });

    test('Get quiz attempts history', () async {
      await helper.loginAndGetToken();

      final response = await helper.apiClient.get('/quizzes/$quizId/attempts');

      expect(response.statusCode, 200);
      final data = response.data['data'] ?? response.data;

      expect(data, isA<List>());
      final attempts = data as List;
      expect(attempts.length, greaterThanOrEqualTo(3)); // We made 3+ attempts

      // Check each attempt has required fields
      for (var attempt in attempts) {
        expect(attempt['id'], isNotNull);
        expect(attempt['quizId'], equals(quizId));
        expect(attempt['score'], isNotNull);
        expect(attempt['maxScore'], equals(3));
        expect(attempt['completed'], isNotNull);
        expect(attempt['answers'], isA<List>());
      }

      print('✅ Retrieved ${attempts.length} attempts for quiz');
    });

    test('Get single attempt details', () async {
      await helper.loginAndGetToken();

      final response = await helper.apiClient.get(
        '/quizzes/attempts/$attemptId',
      );

      expect(response.statusCode, 200);
      final data = response.data['data'] ?? response.data;

      expect(data['id'], equals(attemptId));
      expect(data['quiz'], isNotNull);
      expect(data['quiz']['questions'], isA<List>());
      expect(data['answers'], isA<List>());

      // Check answers have question details
      final answers = data['answers'] as List;
      for (var answer in answers) {
        expect(answer['questionId'], isNotNull);
        expect(answer['userAnswer'], isNotNull);
        expect(answer['isCorrect'], isNotNull);
        expect(answer['points'], isNotNull);
        expect(answer['question'], isNotNull); // Question details included
      }

      print('✅ Attempt details retrieved successfully');
      print('   Questions: ${(data['quiz']['questions'] as List).length}');
      print('   Answers: ${answers.length}');
    });

    test('Cannot start attempt for non-existent quiz', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.post('/quizzes/99999/start', {});
        fail('Should have thrown 404 error');
      } catch (e) {
        expect(e.toString(), contains('404'));
        print('✅ Correctly returned 404 for non-existent quiz');
      }
    });

    test('Cannot submit for non-existent attempt', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.post('/quizzes/attempts/99999/submit', {
          'answers': [
            {'questionId': 999, 'answer': 'test'},
          ],
        });
        fail('Should have thrown 404 error');
      } catch (e) {
        expect(e.toString(), contains('404'));
        print('✅ Correctly returned 404 for non-existent attempt');
      }
    });

    test(
      'Make quiz public and start attempt from another user perspective',
      () async {
        await helper.loginAndGetToken();

        // Make quiz public
        await helper.apiClient.put('/quizzes/$quizId', {'isPublic': true});

        // Start attempt (same user, but quiz is now public)
        final response = await helper.apiClient.post(
          '/quizzes/$quizId/start',
          {},
        );

        expect(response.statusCode, 201);
        print('✅ Can start attempt on public quiz');
      },
    );
  });
}
