import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helper.dart';

void main() {
  final helper = IntegrationTestHelper();
  int? quizId;
  int? requestId;

  setUpAll(() async {
    await helper.loginAndGetToken();
    print('✅ Backend is running');
  });

  group('Quiz Publish Request Integration Tests', () {
    test('Setup - Create quiz with questions for testing', () async {
      await helper.loginAndGetToken();

      // Create quiz
      final createResponse = await helper.apiClient.post('/quizzes', {
        'title': 'Quiz Publish Test',
        'description': 'Testing quiz publish workflow',
        'difficulty': 'INTERMEDIATE',
      });

      expect(createResponse.statusCode, 201);
      final data = createResponse.data['data'] ?? createResponse.data;
      quizId = data['id'];

      print('✅ Created quiz with ID: $quizId');

      // Add 3 questions
      await helper.apiClient.post('/quizzes/$quizId/questions', {
        'type': 'MULTIPLE_CHOICE',
        'question': 'What is the capital of France?',
        'correctAnswer': 'Paris',
        'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      });

      await helper.apiClient.post('/quizzes/$quizId/questions', {
        'type': 'FILL_IN_BLANK',
        'question': 'The Great Wall is in ___',
        'correctAnswer': 'China',
      });

      await helper.apiClient.post('/quizzes/$quizId/questions', {
        'type': 'MULTIPLE_CHOICE',
        'question': 'How many continents are there?',
        'correctAnswer': '7',
        'options': ['5', '6', '7', '8'],
      });

      print('✅ Added 3 questions to quiz');
    });

    test('Request to publish quiz', () async {
      await helper.loginAndGetToken();

      final response = await helper.apiClient.post(
        '/quizzes/$quizId/publish-request',
        {'message': 'Please review my quiz about world geography'},
      );

      expect(response.statusCode, 201);
      final data = response.data['data'] ?? response.data;
      requestId = data['id'];

      expect(data['quizId'], equals(quizId));
      expect(data['status'], equals('pending'));
      expect(
        data['message'],
        equals('Please review my quiz about world geography'),
      );

      print('✅ Publish request created with ID: $requestId');
    });

    test('Cannot request publish for quiz with no questions', () async {
      await helper.loginAndGetToken();

      // Create empty quiz
      final createResponse = await helper.apiClient.post('/quizzes', {
        'title': 'Empty Quiz',
        'description': 'No questions',
      });

      final emptyQuizId = createResponse.data['data']['id'];

      try {
        await helper.apiClient.post(
          '/quizzes/$emptyQuizId/publish-request',
          {},
        );
        fail('Should have thrown error for quiz with no questions');
      } catch (e) {
        expect(e.toString(), contains('400'));
        expect(e.toString().toLowerCase(), contains('no questions'));
        print('✅ Correctly blocked publish request for quiz with no questions');
      }
    });

    test('Cannot request publish twice for same quiz', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.post('/quizzes/$quizId/publish-request', {
          'message': 'Duplicate request',
        });
        fail('Should have thrown error for duplicate request');
      } catch (e) {
        expect(e.toString(), contains('400'));
        expect(e.toString().toLowerCase(), contains('pending'));
        print('✅ Correctly blocked duplicate publish request');
      }
    });

    test('Admin can view pending publish requests', () async {
      await helper.loginAsAdmin();

      final response = await helper.apiClient.get(
        '/quizzes/admin/publish-requests',
      );

      expect(response.statusCode, 200);
      final data = response.data['data'] ?? response.data;
      expect(data, isA<List>());

      // Find our request
      final ourRequest = data.firstWhere(
        (req) => req['id'] == requestId,
        orElse: () => null,
      );

      expect(ourRequest, isNotNull);
      expect(ourRequest['status'], equals('pending'));
      expect(ourRequest['quiz'], isNotNull);
      expect(ourRequest['quiz']['title'], equals('Quiz Publish Test'));
      expect(ourRequest['quiz']['user'], isNotNull);
      expect(ourRequest['quiz']['questions'], isNotNull);
      expect(ourRequest['quiz']['questions'].length, equals(3));

      print('✅ Admin can view pending requests with full quiz details');
    });

    test('Regular user cannot view admin publish requests', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.get('/quizzes/admin/publish-requests');
        fail('Should have thrown error for non-admin access');
      } catch (e) {
        expect(e.toString(), contains('403'));
        print('✅ Correctly blocked non-admin from viewing requests');
      }
    });

    test('Admin approves publish request', () async {
      await helper.loginAsAdmin();

      final response = await helper.apiClient.put(
        '/quizzes/admin/publish-requests/$requestId',
        {'action': 'approve'},
      );

      expect(response.statusCode, 200);
      final data = response.data['data'] ?? response.data;

      expect(data['status'], equals('approved'));
      expect(data['reviewedBy'], isNotNull);
      expect(data['reviewedAt'], isNotNull);

      print('✅ Publish request approved successfully');

      // Verify quiz is now public
      await helper.loginAndGetToken();
      final quizResponse = await helper.apiClient.get('/quizzes/$quizId');
      final quizData = quizResponse.data['data'] ?? quizResponse.data;
      expect(quizData['isPublic'], isTrue);

      print('✅ Quiz is now public');
    });

    test('Cannot approve already approved request', () async {
      await helper.loginAsAdmin();

      try {
        await helper.apiClient.put(
          '/quizzes/admin/publish-requests/$requestId',
          {'action': 'approve'},
        );
        fail('Should have thrown error for re-approving request');
      } catch (e) {
        expect(e.toString(), contains('400'));
        expect(e.toString().toLowerCase(), contains('approved'));
        print('✅ Correctly blocked re-approval of approved request');
      }
    });

    test('Admin can reject publish request', () async {
      await helper.loginAndGetToken();

      // Create another quiz
      final createResponse = await helper.apiClient.post('/quizzes', {
        'title': 'Quiz to Reject',
        'description': 'This will be rejected',
      });

      final newQuizId = createResponse.data['data']['id'];

      // Add a question
      await helper.apiClient.post('/quizzes/$newQuizId/questions', {
        'type': 'FILL_IN_BLANK',
        'question': 'Test question',
        'correctAnswer': 'answer',
      });

      // Request publish
      final requestResponse = await helper.apiClient.post(
        '/quizzes/$newQuizId/publish-request',
        {'message': 'Please review'},
      );

      final newRequestId = requestResponse.data['data']['id'];

      // Admin rejects
      await helper.loginAsAdmin();
      final rejectResponse = await helper.apiClient.put(
        '/quizzes/admin/publish-requests/$newRequestId',
        {'action': 'reject'},
      );

      expect(rejectResponse.statusCode, 200);
      final data = rejectResponse.data['data'] ?? rejectResponse.data;

      expect(data['status'], equals('rejected'));
      expect(data['reviewedBy'], isNotNull);
      expect(data['reviewedAt'], isNotNull);

      print('✅ Publish request rejected successfully');

      // Verify quiz is still not public
      await helper.loginAndGetToken();
      final quizResponse = await helper.apiClient.get('/quizzes/$newQuizId');
      final quizData = quizResponse.data['data'] ?? quizResponse.data;
      expect(quizData['isPublic'], isFalse);

      print('✅ Quiz remains private after rejection');
    });

    test('Cannot request publish for non-existent quiz', () async {
      await helper.loginAndGetToken();

      try {
        await helper.apiClient.post('/quizzes/99999/publish-request', {});
        fail('Should have thrown error for non-existent quiz');
      } catch (e) {
        expect(e.toString(), contains('404'));
        print('✅ Correctly returned 404 for non-existent quiz');
      }
    });

    test('Cannot review non-existent publish request', () async {
      await helper.loginAsAdmin();

      try {
        await helper.apiClient.put('/quizzes/admin/publish-requests/99999', {
          'action': 'approve',
        });
        fail('Should have thrown error for non-existent request');
      } catch (e) {
        expect(e.toString(), contains('404'));
        print('✅ Correctly returned 404 for non-existent request');
      }
    });

    test('Regular user cannot approve/reject requests', () async {
      await helper.loginAndGetToken();

      // Create new quiz and request
      final createResponse = await helper.apiClient.post('/quizzes', {
        'title': 'Another Quiz',
        'description': 'For testing permissions',
      });

      final testQuizId = createResponse.data['data']['id'];

      await helper.apiClient.post('/quizzes/$testQuizId/questions', {
        'type': 'FILL_IN_BLANK',
        'question': 'Question',
        'correctAnswer': 'answer',
      });

      final requestResponse = await helper.apiClient.post(
        '/quizzes/$testQuizId/publish-request',
        {},
      );

      final testRequestId = requestResponse.data['data']['id'];

      // Try to approve as regular user
      try {
        await helper.apiClient.put(
          '/quizzes/admin/publish-requests/$testRequestId',
          {'action': 'approve'},
        );
        fail('Should have thrown error for non-admin approval');
      } catch (e) {
        expect(e.toString(), contains('403'));
        print('✅ Correctly blocked non-admin from approving');
      }
    });
  });
}
