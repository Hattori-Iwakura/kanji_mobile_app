import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:kanji_flutter/features/quiz/domain/entities/quiz_entity.dart';
import 'package:kanji_flutter/features/quiz/domain/entities/quiz_question_entity.dart';
import 'package:kanji_flutter/features/quiz/domain/entities/quiz_attempt_entity.dart';
import 'package:kanji_flutter/features/quiz/domain/entities/quiz_exception.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/add_question_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/approve_publish_request_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/create_quiz_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/delete_question_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/delete_quiz_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/get_all_quizzes_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/get_pending_publish_requests_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/get_quiz_attempt_details_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/get_quiz_attempts_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/get_quiz_by_id_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/reject_publish_request_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/reorder_questions_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/request_publish_quiz_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/start_quiz_attempt_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/submit_quiz_attempt_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/update_question_usecase.dart';
import 'package:kanji_flutter/features/quiz/domain/usecases/update_quiz_usecase.dart';
import 'package:kanji_flutter/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:kanji_flutter/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:kanji_flutter/features/quiz/presentation/bloc/quiz_state.dart';

import 'quiz_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllQuizzesUseCase,
  GetQuizByIdUseCase,
  CreateQuizUseCase,
  UpdateQuizUseCase,
  DeleteQuizUseCase,
  AddQuestionUseCase,
  UpdateQuestionUseCase,
  DeleteQuestionUseCase,
  ReorderQuestionsUseCase,
  StartQuizAttemptUseCase,
  SubmitQuizAttemptUseCase,
  GetQuizAttemptsUseCase,
  GetQuizAttemptDetailsUseCase,
  RequestPublishQuizUseCase,
  GetPendingPublishRequestsUseCase,
  ApprovePublishRequestUseCase,
  RejectPublishRequestUseCase,
])
void main() {
  late QuizBloc quizBloc;
  late MockGetAllQuizzesUseCase mockGetAllQuizzesUseCase;
  late MockGetQuizByIdUseCase mockGetQuizByIdUseCase;
  late MockCreateQuizUseCase mockCreateQuizUseCase;
  late MockUpdateQuizUseCase mockUpdateQuizUseCase;
  late MockDeleteQuizUseCase mockDeleteQuizUseCase;
  late MockAddQuestionUseCase mockAddQuestionUseCase;
  late MockUpdateQuestionUseCase mockUpdateQuestionUseCase;
  late MockDeleteQuestionUseCase mockDeleteQuestionUseCase;
  late MockReorderQuestionsUseCase mockReorderQuestionsUseCase;
  late MockStartQuizAttemptUseCase mockStartQuizAttemptUseCase;
  late MockSubmitQuizAttemptUseCase mockSubmitQuizAttemptUseCase;
  late MockGetQuizAttemptsUseCase mockGetQuizAttemptsUseCase;
  late MockGetQuizAttemptDetailsUseCase mockGetQuizAttemptDetailsUseCase;
  late MockRequestPublishQuizUseCase mockRequestPublishQuizUseCase;
  late MockGetPendingPublishRequestsUseCase
  mockGetPendingPublishRequestsUseCase;
  late MockApprovePublishRequestUseCase mockApprovePublishRequestUseCase;
  late MockRejectPublishRequestUseCase mockRejectPublishRequestUseCase;

  setUp(() {
    mockGetAllQuizzesUseCase = MockGetAllQuizzesUseCase();
    mockGetQuizByIdUseCase = MockGetQuizByIdUseCase();
    mockCreateQuizUseCase = MockCreateQuizUseCase();
    mockUpdateQuizUseCase = MockUpdateQuizUseCase();
    mockDeleteQuizUseCase = MockDeleteQuizUseCase();
    mockAddQuestionUseCase = MockAddQuestionUseCase();
    mockUpdateQuestionUseCase = MockUpdateQuestionUseCase();
    mockDeleteQuestionUseCase = MockDeleteQuestionUseCase();
    mockReorderQuestionsUseCase = MockReorderQuestionsUseCase();
    mockStartQuizAttemptUseCase = MockStartQuizAttemptUseCase();
    mockSubmitQuizAttemptUseCase = MockSubmitQuizAttemptUseCase();
    mockGetQuizAttemptsUseCase = MockGetQuizAttemptsUseCase();
    mockGetQuizAttemptDetailsUseCase = MockGetQuizAttemptDetailsUseCase();
    mockRequestPublishQuizUseCase = MockRequestPublishQuizUseCase();
    mockGetPendingPublishRequestsUseCase =
        MockGetPendingPublishRequestsUseCase();
    mockApprovePublishRequestUseCase = MockApprovePublishRequestUseCase();
    mockRejectPublishRequestUseCase = MockRejectPublishRequestUseCase();

    quizBloc = QuizBloc(
      getAllQuizzesUseCase: mockGetAllQuizzesUseCase,
      getQuizByIdUseCase: mockGetQuizByIdUseCase,
      createQuizUseCase: mockCreateQuizUseCase,
      updateQuizUseCase: mockUpdateQuizUseCase,
      deleteQuizUseCase: mockDeleteQuizUseCase,
      addQuestionUseCase: mockAddQuestionUseCase,
      updateQuestionUseCase: mockUpdateQuestionUseCase,
      deleteQuestionUseCase: mockDeleteQuestionUseCase,
      reorderQuestionsUseCase: mockReorderQuestionsUseCase,
      startQuizAttemptUseCase: mockStartQuizAttemptUseCase,
      submitQuizAttemptUseCase: mockSubmitQuizAttemptUseCase,
      getQuizAttemptsUseCase: mockGetQuizAttemptsUseCase,
      getQuizAttemptDetailsUseCase: mockGetQuizAttemptDetailsUseCase,
      requestPublishQuizUseCase: mockRequestPublishQuizUseCase,
      getPendingPublishRequestsUseCase: mockGetPendingPublishRequestsUseCase,
      approvePublishRequestUseCase: mockApprovePublishRequestUseCase,
      rejectPublishRequestUseCase: mockRejectPublishRequestUseCase,
    );
  });

  tearDown(() {
    quizBloc.close();
  });

  final tQuiz = QuizEntity(
    id: 1,
    title: 'N5 Reading Quiz',
    description: 'Test your N5 reading skills',
    userId: 1,
    isPublic: true,
    totalQuestions: 10,
    createAt: DateTime(2024, 1, 1),
    updateAt: DateTime(2024, 1, 1),
  );

  final tQuizzes = [tQuiz];

  final tQuestion = QuizQuestionEntity(
    id: 1,
    quizId: 1,
    kanjiId: 1,
    questionText: 'What is the reading?',
    questionType: 'multiple_choice',
    options: ['a', 'b', 'c', 'd'],
    correctAnswer: 'a',
    orderIndex: 1,
    createAt: DateTime(2024, 1, 1),
    updateAt: DateTime(2024, 1, 1),
  );

  final tAttempt = QuizAttemptEntity(
    id: 1,
    quizId: 1,
    userId: 1,
    score: 0,
    totalQuestions: 10,
    correctAnswers: 0,
    startedAt: DateTime(2024, 1, 1, 10, 0),
    completedAt: null,
    status: 'in_progress',
  );

  final tCompletedAttempt = QuizAttemptEntity(
    id: 1,
    quizId: 1,
    userId: 1,
    score: 85,
    totalQuestions: 10,
    correctAnswers: 8,
    startedAt: DateTime(2024, 1, 1, 10, 0),
    completedAt: DateTime(2024, 1, 1, 10, 30),
    status: 'completed',
  );

  group('QuizBloc', () {
    test('initial state is QuizInitial', () {
      expect(quizBloc.state, QuizInitial());
    });

    group('GetAllQuizzesEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizzesLoaded] when loading succeeds',
        build: () {
          when(
            mockGetAllQuizzesUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tQuizzes);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetAllQuizzesEvent()),
        expect: () => [QuizLoading(), QuizzesLoaded(tQuizzes)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizzesLoaded] with search filter',
        build: () {
          when(
            mockGetAllQuizzesUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenAnswer((_) async => tQuizzes);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetAllQuizzesEvent(search: 'N5')),
        expect: () => [QuizLoading(), QuizzesLoaded(tQuizzes)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when loading fails',
        build: () {
          when(
            mockGetAllQuizzesUseCase.call(
              search: anyNamed('search'),
              limit: anyNamed('limit'),
              offset: anyNamed('offset'),
            ),
          ).thenThrow(QuizException(message: 'Network error'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetAllQuizzesEvent()),
        expect: () => [QuizLoading(), const QuizError('Network error')],
      );
    });

    group('GetQuizByIdEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizLoaded] when loading by ID succeeds',
        build: () {
          when(mockGetQuizByIdUseCase.call(any)).thenAnswer((_) async => tQuiz);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetQuizByIdEvent(1)),
        expect: () => [QuizLoading(), QuizLoaded(tQuiz)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when quiz not found',
        build: () {
          when(
            mockGetQuizByIdUseCase.call(any),
          ).thenThrow(QuizException(message: 'Quiz not found'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetQuizByIdEvent(999)),
        expect: () => [QuizLoading(), const QuizError('Quiz not found')],
      );
    });

    group('CreateQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizCreated] when creation succeeds',
        build: () {
          when(
            mockCreateQuizUseCase.call(
              title: anyNamed('title'),
              description: anyNamed('description'),
            ),
          ).thenAnswer((_) async => tQuiz);
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const CreateQuizEvent(title: 'My Quiz', description: 'Test quiz'),
        ),
        expect: () => [QuizLoading(), QuizCreated(tQuiz)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when title is empty',
        build: () {
          when(
            mockCreateQuizUseCase.call(
              title: anyNamed('title'),
              description: anyNamed('description'),
            ),
          ).thenThrow(QuizException(message: 'Title is required'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(const CreateQuizEvent(title: '')),
        expect: () => [QuizLoading(), const QuizError('Title is required')],
      );
    });

    group('UpdateQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizUpdated] when update succeeds',
        build: () {
          when(
            mockUpdateQuizUseCase.call(
              id: anyNamed('id'),
              title: anyNamed('title'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenAnswer((_) async => tQuiz);
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateQuizEvent(
            id: 1,
            title: 'Updated Quiz',
            description: 'Updated description',
            isPublic: true,
          ),
        ),
        expect: () => [QuizLoading(), QuizUpdated(tQuiz)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when quiz not found',
        build: () {
          when(
            mockUpdateQuizUseCase.call(
              id: anyNamed('id'),
              title: anyNamed('title'),
              description: anyNamed('description'),
              isPublic: anyNamed('isPublic'),
            ),
          ).thenThrow(QuizException(message: 'Quiz not found'));
          return quizBloc;
        },
        act: (bloc) =>
            bloc.add(const UpdateQuizEvent(id: 999, title: 'Updated')),
        expect: () => [QuizLoading(), const QuizError('Quiz not found')],
      );
    });

    group('DeleteQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizDeleted] when deletion succeeds',
        build: () {
          when(mockDeleteQuizUseCase.call(any)).thenAnswer((_) async => {});
          return quizBloc;
        },
        act: (bloc) => bloc.add(const DeleteQuizEvent(1)),
        expect: () => [QuizLoading(), QuizDeleted()],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when deletion fails - unauthorized',
        build: () {
          when(
            mockDeleteQuizUseCase.call(any),
          ).thenThrow(QuizException(message: 'Unauthorized'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(const DeleteQuizEvent(1)),
        expect: () => [QuizLoading(), const QuizError('Unauthorized')],
      );
    });

    group('AddQuestionEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuestionAdded] when adding question succeeds',
        build: () {
          when(
            mockAddQuestionUseCase.call(
              quizId: anyNamed('quizId'),
              kanjiId: anyNamed('kanjiId'),
              questionText: anyNamed('questionText'),
              questionType: anyNamed('questionType'),
              options: anyNamed('options'),
              correctAnswer: anyNamed('correctAnswer'),
            ),
          ).thenAnswer((_) async => tQuestion);
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const AddQuestionEvent(
            quizId: 1,
            kanjiId: 1,
            questionText: 'What is the reading?',
            questionType: 'multiple_choice',
            options: ['a', 'b', 'c', 'd'],
            correctAnswer: 'a',
          ),
        ),
        expect: () => [QuizLoading(), QuestionAdded(tQuestion)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when quiz not found',
        build: () {
          when(
            mockAddQuestionUseCase.call(
              quizId: anyNamed('quizId'),
              kanjiId: anyNamed('kanjiId'),
              questionText: anyNamed('questionText'),
              questionType: anyNamed('questionType'),
              options: anyNamed('options'),
              correctAnswer: anyNamed('correctAnswer'),
            ),
          ).thenThrow(QuizException(message: 'Quiz not found'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const AddQuestionEvent(
            quizId: 999,
            kanjiId: 1,
            questionText: 'Test',
            questionType: 'multiple_choice',
            options: ['a', 'b'],
            correctAnswer: 'a',
          ),
        ),
        expect: () => [QuizLoading(), const QuizError('Quiz not found')],
      );
    });

    group('UpdateQuestionEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuestionUpdated] when update succeeds',
        build: () {
          when(
            mockUpdateQuestionUseCase.call(
              quizId: anyNamed('quizId'),
              questionId: anyNamed('questionId'),
              questionText: anyNamed('questionText'),
              questionType: anyNamed('questionType'),
              options: anyNamed('options'),
              correctAnswer: anyNamed('correctAnswer'),
            ),
          ).thenAnswer((_) async => tQuestion);
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateQuestionEvent(
            quizId: 1,
            questionId: 1,
            questionText: 'Updated question',
          ),
        ),
        expect: () => [QuizLoading(), QuestionUpdated(tQuestion)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when question not found',
        build: () {
          when(
            mockUpdateQuestionUseCase.call(
              quizId: anyNamed('quizId'),
              questionId: anyNamed('questionId'),
              questionText: anyNamed('questionText'),
              questionType: anyNamed('questionType'),
              options: anyNamed('options'),
              correctAnswer: anyNamed('correctAnswer'),
            ),
          ).thenThrow(QuizException(message: 'Question not found'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const UpdateQuestionEvent(
            quizId: 1,
            questionId: 999,
            questionText: 'Updated',
          ),
        ),
        expect: () => [QuizLoading(), const QuizError('Question not found')],
      );
    });

    group('DeleteQuestionEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuestionDeleted] when deletion succeeds',
        build: () {
          when(
            mockDeleteQuestionUseCase.call(
              quizId: anyNamed('quizId'),
              questionId: anyNamed('questionId'),
            ),
          ).thenAnswer((_) async => {});
          return quizBloc;
        },
        act: (bloc) =>
            bloc.add(const DeleteQuestionEvent(quizId: 1, questionId: 1)),
        expect: () => [QuizLoading(), QuestionDeleted()],
      );
    });

    group('ReorderQuestionsEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuestionsReordered] when reordering succeeds',
        build: () {
          when(
            mockReorderQuestionsUseCase.call(
              quizId: anyNamed('quizId'),
              questionOrders: anyNamed('questionOrders'),
            ),
          ).thenAnswer((_) async => {});
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const ReorderQuestionsEvent(
            quizId: 1,
            questionOrders: [
              {'questionId': 1, 'order': 2},
              {'questionId': 2, 'order': 1},
            ],
          ),
        ),
        expect: () => [QuizLoading(), QuestionsReordered()],
      );
    });

    group('StartQuizAttemptEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizAttemptStarted] when starting succeeds',
        build: () {
          when(
            mockStartQuizAttemptUseCase.call(any),
          ).thenAnswer((_) async => tAttempt);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const StartQuizAttemptEvent(1)),
        expect: () => [QuizLoading(), QuizAttemptStarted(tAttempt)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when quiz has no questions',
        build: () {
          when(
            mockStartQuizAttemptUseCase.call(any),
          ).thenThrow(QuizException(message: 'Quiz has no questions'));
          return quizBloc;
        },
        act: (bloc) => bloc.add(const StartQuizAttemptEvent(1)),
        expect: () => [QuizLoading(), const QuizError('Quiz has no questions')],
      );
    });

    group('SubmitQuizAttemptEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizAttemptSubmitted] when submission succeeds',
        build: () {
          when(
            mockSubmitQuizAttemptUseCase.call(
              attemptId: anyNamed('attemptId'),
              answers: anyNamed('answers'),
            ),
          ).thenAnswer((_) async => tCompletedAttempt);
          return quizBloc;
        },
        act: (bloc) => bloc.add(
          const SubmitQuizAttemptEvent(
            attemptId: 1,
            answers: [
              {'questionId': 1, 'answer': 'a'},
              {'questionId': 2, 'answer': 'b'},
            ],
          ),
        ),
        expect: () => [QuizLoading(), QuizAttemptSubmitted(tCompletedAttempt)],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when attempt already completed',
        build: () {
          when(
            mockSubmitQuizAttemptUseCase.call(
              attemptId: anyNamed('attemptId'),
              answers: anyNamed('answers'),
            ),
          ).thenThrow(QuizException(message: 'Attempt already completed'));
          return quizBloc;
        },
        act: (bloc) =>
            bloc.add(const SubmitQuizAttemptEvent(attemptId: 1, answers: [])),
        expect: () => [
          QuizLoading(),
          const QuizError('Attempt already completed'),
        ],
      );
    });

    group('GetQuizAttemptsEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizAttemptsLoaded] when loading succeeds',
        build: () {
          when(
            mockGetQuizAttemptsUseCase.call(any),
          ).thenAnswer((_) async => [tCompletedAttempt]);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetQuizAttemptsEvent(1)),
        expect: () => [
          QuizLoading(),
          QuizAttemptsLoaded([tCompletedAttempt]),
        ],
      );
    });

    group('GetQuizAttemptDetailsEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizAttemptDetailsLoaded] when loading succeeds',
        build: () {
          when(
            mockGetQuizAttemptDetailsUseCase.call(any),
          ).thenAnswer((_) async => tCompletedAttempt);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetQuizAttemptDetailsEvent(1)),
        expect: () => [
          QuizLoading(),
          QuizAttemptDetailsLoaded(tCompletedAttempt),
        ],
      );
    });

    group('RequestPublishEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, PublishRequested] when request succeeds',
        build: () {
          when(
            mockRequestPublishQuizUseCase.call(any, any),
          ).thenAnswer((_) async => {});
          return quizBloc;
        },
        act: (bloc) => bloc.add(const RequestPublishEvent(quizId: 1)),
        expect: () => [QuizLoading(), PublishRequested()],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when quiz has no questions',
        build: () {
          when(mockRequestPublishQuizUseCase.call(any, any)).thenThrow(
            QuizException(message: 'Quiz must have at least one question'),
          );
          return quizBloc;
        },
        act: (bloc) => bloc.add(const RequestPublishEvent(quizId: 1)),
        expect: () => [
          QuizLoading(),
          const QuizError('Quiz must have at least one question'),
        ],
      );
    });

    group('GetPendingPublishRequestsEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, PublishRequestsLoaded] when loading succeeds',
        build: () {
          when(
            mockGetPendingPublishRequestsUseCase.call(),
          ).thenAnswer((_) async => []);
          return quizBloc;
        },
        act: (bloc) => bloc.add(const GetPendingPublishRequestsEvent()),
        expect: () => [QuizLoading(), const PublishRequestsLoaded([])],
      );
    });

    group('ApprovePublishRequestEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, PublishRequestApproved] when approval succeeds',
        build: () {
          when(
            mockApprovePublishRequestUseCase.call(any),
          ).thenAnswer((_) async => {});
          return quizBloc;
        },
        act: (bloc) => bloc.add(const ApprovePublishRequestEvent(1)),
        expect: () => [QuizLoading(), PublishRequestApproved()],
      );
    });

    group('RejectPublishRequestEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, PublishRequestRejected] when rejection succeeds',
        build: () {
          when(
            mockRejectPublishRequestUseCase.call(any),
          ).thenAnswer((_) async => {});
          return quizBloc;
        },
        act: (bloc) => bloc.add(const RejectPublishRequestEvent(1)),
        expect: () => [QuizLoading(), PublishRequestRejected()],
      );
    });

    group('Multiple Events Sequence', () {
      blocTest<QuizBloc, QuizState>(
        'handles create quiz followed by add question',
        build: () {
          when(
            mockCreateQuizUseCase.call(
              title: anyNamed('title'),
              description: anyNamed('description'),
            ),
          ).thenAnswer((_) async => tQuiz);
          when(
            mockAddQuestionUseCase.call(
              quizId: anyNamed('quizId'),
              kanjiId: anyNamed('kanjiId'),
              questionText: anyNamed('questionText'),
              questionType: anyNamed('questionType'),
              options: anyNamed('options'),
              correctAnswer: anyNamed('correctAnswer'),
            ),
          ).thenAnswer((_) async => tQuestion);
          return quizBloc;
        },
        act: (bloc) {
          bloc.add(const CreateQuizEvent(title: 'New Quiz'));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(
              const AddQuestionEvent(
                quizId: 1,
                kanjiId: 1,
                questionText: 'Test',
                questionType: 'multiple_choice',
                options: ['a', 'b'],
                correctAnswer: 'a',
              ),
            );
          });
        },
        expect: () => [
          QuizLoading(),
          QuizCreated(tQuiz),
          QuizLoading(),
          QuestionAdded(tQuestion),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'handles start attempt followed by submit',
        build: () {
          when(
            mockStartQuizAttemptUseCase.call(any),
          ).thenAnswer((_) async => tAttempt);
          when(
            mockSubmitQuizAttemptUseCase.call(
              attemptId: anyNamed('attemptId'),
              answers: anyNamed('answers'),
            ),
          ).thenAnswer((_) async => tCompletedAttempt);
          return quizBloc;
        },
        act: (bloc) {
          bloc.add(const StartQuizAttemptEvent(1));
          return Future.delayed(const Duration(milliseconds: 100), () {
            bloc.add(
              const SubmitQuizAttemptEvent(
                attemptId: 1,
                answers: [
                  {'questionId': 1, 'answer': 'a'},
                ],
              ),
            );
          });
        },
        expect: () => [
          QuizLoading(),
          QuizAttemptStarted(tAttempt),
          QuizLoading(),
          QuizAttemptSubmitted(tCompletedAttempt),
        ],
      );
    });
  });
}
