import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_mobile_app/injection_container.dart' as di;
import 'package:kanji_mobile_app/features/quiz/domain/usecases/get_quizzes.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/get_quiz_detail.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/create_quiz.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/update_quiz.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/delete_quiz.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/add_question.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/update_question.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/delete_question.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/start_quiz_attempt.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/submit_quiz_attempt.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/get_quiz_attempts.dart';
import 'package:kanji_mobile_app/features/quiz/domain/usecases/get_quiz_attempt_details.dart';
import 'package:kanji_mobile_app/features/quiz/domain/entities/question.dart';
import 'package:kanji_mobile_app/features/quiz/domain/entities/quiz.dart';
import 'package:kanji_mobile_app/features/quiz/domain/entities/quiz_attempt.dart';
import '../helpers/test_helper.dart';
import '../helpers/auth_helper.dart';

void main() {
  setUpAll(() async {
    TestHelper.printSection('INITIALIZING QUIZ INTEGRATION TESTS');

    // Step 1: Initialize dependencies FIRST (this resets GetIt and creates new instances)
    await TestHelper.initializeDependencies();
    TestHelper.printSuccess('Dependencies initialized');

    // Step 2: Setup authentication AFTER dependencies are initialized
    // This ensures token is set on the actual ApiClient instance being used
    TestHelper.printStep('Setting up authentication...');
    try {
      await AuthHelper.setupAuth();
      TestHelper.printSuccess('Authentication configured successfully');
    } catch (e) {
      TestHelper.printError('Failed to setup auth: $e');
      TestHelper.printStep('Tests may fail due to authentication issues');
      rethrow; // Stop tests if auth fails
    }
  });

  tearDownAll(() {
    // Clean up authentication
    AuthHelper.clearAuth();
  });

  group('1. Quiz Management Tests -', () {
    late GetQuizzesUseCase getQuizzes;
    late GetQuizDetailUseCase getQuizDetail;
    late CreateQuizUseCase createQuiz;
    late UpdateQuizUseCase updateQuiz;
    late DeleteQuizUseCase deleteQuiz;

    setUp(() {
      getQuizzes = di.sl<GetQuizzesUseCase>();
      getQuizDetail = di.sl<GetQuizDetailUseCase>();
      createQuiz = di.sl<CreateQuizUseCase>();
      updateQuiz = di.sl<UpdateQuizUseCase>();
      deleteQuiz = di.sl<DeleteQuizUseCase>();
    });

    test('1.1. Get all quizzes', () async {
      TestHelper.printSection('TEST 1.1: GET ALL QUIZZES');

      try {
        final result = await getQuizzes(limit: 10, offset: 0, search: null);

        TestHelper.printSuccess(
          'Got response with ${result['data'].length} quizzes',
        );
        expect(result, isA<Map<String, dynamic>>());
        expect(result['data'], isA<List>());
        expect(result['total'], isA<int>());
      } catch (e) {
        TestHelper.printError('Failed to get quizzes: $e');
        fail('Should get quizzes successfully');
      }
    });

    test('1.2. Get quiz detail', () async {
      TestHelper.printSection('TEST 1.2: GET QUIZ DETAIL');

      try {
        // First get list of quizzes
        final listResult = await getQuizzes(limit: 10, offset: 0);
        final quizzes = listResult['data'] as List<Quiz>;

        if (quizzes.isEmpty) {
          TestHelper.printStep('No quizzes available to test');
          return;
        }

        final quizId = quizzes.first.id;
        TestHelper.printStep('Testing with quiz ID: $quizId');

        final quiz = await getQuizDetail(quizId);

        TestHelper.printSuccess('Quiz: ${quiz.title}');
        TestHelper.printSuccess('Questions: ${quiz.questions?.length ?? 0}');
        expect(quiz, isA<Quiz>());
        expect(quiz.id, equals(quizId));
      } catch (e) {
        TestHelper.printError('Failed to get quiz detail: $e');
        fail('Should get quiz detail successfully');
      }
    });

    test('1.3. Create quiz', () async {
      TestHelper.printSection('TEST 1.3: CREATE QUIZ');

      try {
        final quiz = await createQuiz(
          title: 'Test Quiz ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Integration test quiz',
        );

        TestHelper.printSuccess('Created quiz: ${quiz.title}');
        TestHelper.printSuccess('Quiz ID: ${quiz.id}');
        expect(quiz, isA<Quiz>());
        expect(quiz.id, isPositive);
        expect(quiz.title, isNotEmpty);

        // Clean up
        await deleteQuiz(quiz.id);
        TestHelper.printSuccess('Cleaned up quiz ID: ${quiz.id}');
      } catch (e) {
        TestHelper.printError('Failed to create quiz: $e');
        fail('Should create quiz successfully');
      }
    });

    test('1.4. Update quiz', () async {
      TestHelper.printSection('TEST 1.4: UPDATE QUIZ');

      try {
        // Create a quiz first
        final quiz = await createQuiz(
          title: 'Quiz to Update ${DateTime.now().millisecondsSinceEpoch}',
          description: 'Original description',
        );

        TestHelper.printSuccess('Created quiz ID: ${quiz.id}');

        // Update the quiz
        final updatedQuiz = await updateQuiz(
          quizId: quiz.id,
          title: 'Updated Quiz Title',
          description: 'Updated description',
        );

        TestHelper.printSuccess('Updated quiz: ${updatedQuiz.title}');
        expect(updatedQuiz.id, equals(quiz.id));
        expect(updatedQuiz.title, equals('Updated Quiz Title'));
        expect(updatedQuiz.description, equals('Updated description'));

        // Clean up
        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed to update quiz: $e');
        fail('Should update quiz successfully');
      }
    });

    test('1.5. Delete quiz', () async {
      TestHelper.printSection('TEST 1.5: DELETE QUIZ');

      try {
        // Create a quiz to delete
        final quiz = await createQuiz(
          title: 'Quiz to Delete ${DateTime.now().millisecondsSinceEpoch}',
        );

        TestHelper.printSuccess('Created quiz ID: ${quiz.id}');

        // Delete the quiz
        await deleteQuiz(quiz.id);
        TestHelper.printSuccess('Deleted quiz ID: ${quiz.id}');

        // Verify quiz is deleted
        try {
          await getQuizDetail(quiz.id);
          fail('Quiz should be deleted');
        } catch (e) {
          TestHelper.printSuccess('Quiz not found (as expected)');
        }
      } catch (e) {
        TestHelper.printError('Failed test: $e');
        fail('Should complete delete test successfully');
      }
    });
  });

  group('2. Question Management Tests -', () {
    late CreateQuizUseCase createQuiz;
    late AddQuestionUseCase addQuestion;
    late UpdateQuestionUseCase updateQuestion;
    late DeleteQuestionUseCase deleteQuestion;
    late GetQuizDetailUseCase getQuizDetail;
    late DeleteQuizUseCase deleteQuiz;

    setUp(() {
      createQuiz = di.sl<CreateQuizUseCase>();
      addQuestion = di.sl<AddQuestionUseCase>();
      updateQuestion = di.sl<UpdateQuestionUseCase>();
      deleteQuestion = di.sl<DeleteQuestionUseCase>();
      getQuizDetail = di.sl<GetQuizDetailUseCase>();
      deleteQuiz = di.sl<DeleteQuizUseCase>();
    });

    test('2.1. Add multiple choice question', () async {
      TestHelper.printSection('TEST 2.1: ADD MULTIPLE CHOICE QUESTION');

      try {
        // Create a quiz first
        final quiz = await createQuiz(
          title: 'Quiz for MC ${DateTime.now().millisecondsSinceEpoch}',
        );

        TestHelper.printSuccess('Created quiz ID: ${quiz.id}');

        // Add a multiple choice question
        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.multipleChoice,
          questionText: 'What is the meaning of 日本?',
          correctAnswer: 'Japan',
          options: ['Japan', 'China', 'Korea', 'America'],
          points: 10,
          explanation: '日本 means Japan',
        );

        TestHelper.printSuccess('Added question: ${question.questionText}');
        TestHelper.printSuccess('Question ID: ${question.id}');
        expect(question, isA<Question>());
        expect(question.type, equals(QuestionType.multipleChoice));
        expect(question.options, hasLength(4));

        // Clean up
        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed to add question: $e');
        fail('Should add question successfully');
      }
    });

    test('2.2. Add fill blank question', () async {
      TestHelper.printSection('TEST 2.2: ADD FILL BLANK QUESTION');

      try {
        final quiz = await createQuiz(
          title: 'Quiz for Fill Blank ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'How do you say hello in Japanese?',
          correctAnswer: 'こんにちは',
          points: 5,
        );

        TestHelper.printSuccess('Added question: ${question.questionText}');
        expect(question.type, equals(QuestionType.fillBlank));
        expect(question.options, isNull);

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should add fill blank question successfully');
      }
    });

    test('2.3. Update question', () async {
      TestHelper.printSection('TEST 2.3: UPDATE QUESTION');

      try {
        final quiz = await createQuiz(
          title: 'Quiz for Update ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'Original question',
          correctAnswer: 'original',
          points: 5,
        );

        TestHelper.printSuccess('Added question ID: ${question.id}');

        // Update the question
        final updatedQuestion = await updateQuestion(
          quizId: quiz.id,
          questionId: question.id,
          type: QuestionType.fillBlank,
          questionText: 'Updated question',
          correctAnswer: 'updated',
          points: 15,
        );

        TestHelper.printSuccess('Updated: ${updatedQuestion.questionText}');
        expect(updatedQuestion.id, equals(question.id));
        expect(updatedQuestion.questionText, equals('Updated question'));
        expect(updatedQuestion.points, equals(15));

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should update question successfully');
      }
    });

    test('2.4. Delete question', () async {
      TestHelper.printSection('TEST 2.4: DELETE QUESTION');

      try {
        final quiz = await createQuiz(
          title: 'Quiz for Delete ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'Question to delete',
          correctAnswer: 'delete me',
          points: 5,
        );

        TestHelper.printSuccess('Added question ID: ${question.id}');

        // Delete the question
        await deleteQuestion(quizId: quiz.id, questionId: question.id);
        TestHelper.printSuccess('Deleted question ID: ${question.id}');

        // Verify question is deleted
        final updatedQuiz = await getQuizDetail(quiz.id);
        final exists =
            updatedQuiz.questions?.any((q) => q.id == question.id) ?? false;
        expect(exists, isFalse);
        TestHelper.printSuccess('Question removed from quiz');

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should delete question successfully');
      }
    });
  });

  group('3. Quiz Attempt Tests -', () {
    late CreateQuizUseCase createQuiz;
    late AddQuestionUseCase addQuestion;
    late StartQuizAttemptUseCase startQuizAttempt;
    late SubmitQuizAttemptUseCase submitQuizAttempt;
    late GetQuizAttemptsUseCase getQuizAttempts;
    late GetQuizAttemptDetailsUseCase getQuizAttemptDetails;
    late DeleteQuizUseCase deleteQuiz;

    setUp(() {
      createQuiz = di.sl<CreateQuizUseCase>();
      addQuestion = di.sl<AddQuestionUseCase>();
      startQuizAttempt = di.sl<StartQuizAttemptUseCase>();
      submitQuizAttempt = di.sl<SubmitQuizAttemptUseCase>();
      getQuizAttempts = di.sl<GetQuizAttemptsUseCase>();
      getQuizAttemptDetails = di.sl<GetQuizAttemptDetailsUseCase>();
      deleteQuiz = di.sl<DeleteQuizUseCase>();
    });

    test('3.1. Start quiz attempt', () async {
      TestHelper.printSection('TEST 3.1: START QUIZ ATTEMPT');

      try {
        final quiz = await createQuiz(
          title: 'Quiz for Attempt ${DateTime.now().millisecondsSinceEpoch}',
        );

        await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'Sample question',
          correctAnswer: 'answer',
          points: 10,
        );

        TestHelper.printSuccess('Created quiz with question');

        // Start quiz attempt
        final attempt = await startQuizAttempt(quiz.id);

        TestHelper.printSuccess('Started attempt ID: ${attempt.id}');
        expect(attempt, isA<QuizAttempt>());
        expect(attempt.quizId, equals(quiz.id));

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should start quiz attempt successfully');
      }
    });

    test('3.2. Submit quiz with correct answer', () async {
      TestHelper.printSection('TEST 3.2: SUBMIT QUIZ WITH CORRECT ANSWER');

      try {
        final quiz = await createQuiz(
          title: 'Quiz Submit ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'What is 1+1?',
          correctAnswer: '2',
          points: 10,
        );

        final attempt = await startQuizAttempt(quiz.id);
        TestHelper.printSuccess('Started attempt ID: ${attempt.id}');

        // Submit with correct answer
        final result = await submitQuizAttempt(
          attemptId: attempt.id,
          answers: [
            {'questionId': question.id, 'answer': '2'},
          ],
        );

        TestHelper.printSuccess('Score: ${result.score}/${result.maxScore}');
        TestHelper.printSuccess('Percentage: ${result.percentage}%');
        expect(result.score, equals(10));
        expect(result.percentage, equals(100.0));
        expect(result.completed, isTrue);

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should submit quiz successfully');
      }
    });

    test('3.3. Submit quiz with wrong answer', () async {
      TestHelper.printSection('TEST 3.3: SUBMIT QUIZ WITH WRONG ANSWER');

      try {
        final quiz = await createQuiz(
          title: 'Quiz Wrong ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'What is 2+2?',
          correctAnswer: '4',
          points: 10,
        );

        final attempt = await startQuizAttempt(quiz.id);

        // Submit with wrong answer
        final result = await submitQuizAttempt(
          attemptId: attempt.id,
          answers: [
            {'questionId': question.id, 'answer': '5'},
          ],
        );

        TestHelper.printSuccess('Score: ${result.score}/${result.maxScore}');
        expect(result.score, equals(0));
        expect(result.percentage, equals(0.0));
        expect(result.correctAnswers, equals(0));

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should submit quiz successfully');
      }
    });

    test('3.4. Get quiz attempts history', () async {
      TestHelper.printSection('TEST 3.4: GET QUIZ ATTEMPTS HISTORY');

      try {
        final quiz = await createQuiz(
          title: 'Quiz History ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.fillBlank,
          questionText: 'Test',
          correctAnswer: 'test',
          points: 10,
        );

        // Make 2 attempts
        for (int i = 0; i < 2; i++) {
          final attempt = await startQuizAttempt(quiz.id);
          await submitQuizAttempt(
            attemptId: attempt.id,
            answers: [
              {'questionId': question.id, 'answer': 'test'},
            ],
          );
        }

        // Get attempts history
        final attempts = await getQuizAttempts(quiz.id);

        TestHelper.printSuccess('Found ${attempts.length} attempts');
        expect(attempts.length, greaterThanOrEqualTo(2));

        for (var attempt in attempts) {
          TestHelper.printSuccess(
            'Attempt ID: ${attempt.id}, Score: ${attempt.score}',
          );
        }

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should get attempts history successfully');
      }
    });

    test('3.5. Get quiz attempt details', () async {
      TestHelper.printSection('TEST 3.5: GET QUIZ ATTEMPT DETAILS');

      try {
        final quiz = await createQuiz(
          title: 'Quiz Details ${DateTime.now().millisecondsSinceEpoch}',
        );

        final question = await addQuestion(
          quizId: quiz.id,
          type: QuestionType.multipleChoice,
          questionText: 'Test question',
          correctAnswer: 'Correct',
          options: ['Correct', 'Wrong1', 'Wrong2'],
          points: 15,
        );

        final attempt = await startQuizAttempt(quiz.id);
        await submitQuizAttempt(
          attemptId: attempt.id,
          answers: [
            {'questionId': question.id, 'answer': 'Correct'},
          ],
        );

        // Get attempt details
        final details = await getQuizAttemptDetails(attempt.id);

        TestHelper.printSuccess('Attempt ID: ${details.id}');
        TestHelper.printSuccess('Score: ${details.score}');
        expect(details.id, equals(attempt.id));
        expect(details.score, equals(15));
        expect(details.answers, hasLength(1));

        await deleteQuiz(quiz.id);
      } catch (e) {
        TestHelper.printError('Failed: $e');
        fail('Should get attempt details successfully');
      }
    });
  });

  group('4. Error Handling Tests -', () {
    late GetQuizDetailUseCase getQuizDetail;
    late StartQuizAttemptUseCase startQuizAttempt;

    setUp(() {
      getQuizDetail = di.sl<GetQuizDetailUseCase>();
      startQuizAttempt = di.sl<StartQuizAttemptUseCase>();
    });

    test('4.1. Get non-existent quiz', () async {
      TestHelper.printSection('TEST 4.1: GET NON-EXISTENT QUIZ');

      try {
        await getQuizDetail(999999);
        fail('Should throw error for non-existent quiz');
      } catch (e) {
        TestHelper.printSuccess('Error handled correctly: $e');
        expect(e, isNotNull);
      }
    });

    test('4.2. Start attempt on non-existent quiz', () async {
      TestHelper.printSection('TEST 4.2: START ATTEMPT ON NON-EXISTENT QUIZ');

      try {
        await startQuizAttempt(999999);
        fail('Should throw error for non-existent quiz');
      } catch (e) {
        TestHelper.printSuccess('Error handled correctly: $e');
        expect(e, isNotNull);
      }
    });
  });
}
