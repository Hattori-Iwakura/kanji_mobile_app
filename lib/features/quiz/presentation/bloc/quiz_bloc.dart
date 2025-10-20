import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quiz_exception.dart';
import '../../domain/usecases/get_all_quizzes_usecase.dart';
import '../../domain/usecases/get_quiz_by_id_usecase.dart';
import '../../domain/usecases/create_quiz_usecase.dart';
import '../../domain/usecases/update_quiz_usecase.dart';
import '../../domain/usecases/delete_quiz_usecase.dart';
import '../../domain/usecases/add_question_usecase.dart';
import '../../domain/usecases/update_question_usecase.dart';
import '../../domain/usecases/delete_question_usecase.dart';
import '../../domain/usecases/reorder_questions_usecase.dart';
import '../../domain/usecases/start_quiz_attempt_usecase.dart';
import '../../domain/usecases/submit_quiz_attempt_usecase.dart';
import '../../domain/usecases/get_quiz_attempts_usecase.dart';
import '../../domain/usecases/get_quiz_attempt_details_usecase.dart';
import '../../domain/usecases/request_publish_quiz_usecase.dart';
import '../../domain/usecases/get_pending_publish_requests_usecase.dart';
import '../../domain/usecases/approve_publish_request_usecase.dart';
import '../../domain/usecases/reject_publish_request_usecase.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetAllQuizzesUseCase getAllQuizzesUseCase;
  final GetQuizByIdUseCase getQuizByIdUseCase;
  final CreateQuizUseCase createQuizUseCase;
  final UpdateQuizUseCase updateQuizUseCase;
  final DeleteQuizUseCase deleteQuizUseCase;
  final AddQuestionUseCase addQuestionUseCase;
  final UpdateQuestionUseCase updateQuestionUseCase;
  final DeleteQuestionUseCase deleteQuestionUseCase;
  final ReorderQuestionsUseCase reorderQuestionsUseCase;
  final StartQuizAttemptUseCase startQuizAttemptUseCase;
  final SubmitQuizAttemptUseCase submitQuizAttemptUseCase;
  final GetQuizAttemptsUseCase getQuizAttemptsUseCase;
  final GetQuizAttemptDetailsUseCase getQuizAttemptDetailsUseCase;
  final RequestPublishQuizUseCase requestPublishQuizUseCase;
  final GetPendingPublishRequestsUseCase getPendingPublishRequestsUseCase;
  final ApprovePublishRequestUseCase approvePublishRequestUseCase;
  final RejectPublishRequestUseCase rejectPublishRequestUseCase;

  QuizBloc({
    required this.getAllQuizzesUseCase,
    required this.getQuizByIdUseCase,
    required this.createQuizUseCase,
    required this.updateQuizUseCase,
    required this.deleteQuizUseCase,
    required this.addQuestionUseCase,
    required this.updateQuestionUseCase,
    required this.deleteQuestionUseCase,
    required this.reorderQuestionsUseCase,
    required this.startQuizAttemptUseCase,
    required this.submitQuizAttemptUseCase,
    required this.getQuizAttemptsUseCase,
    required this.getQuizAttemptDetailsUseCase,
    required this.requestPublishQuizUseCase,
    required this.getPendingPublishRequestsUseCase,
    required this.approvePublishRequestUseCase,
    required this.rejectPublishRequestUseCase,
  }) : super(QuizInitial()) {
    on<GetAllQuizzesEvent>(_onGetAllQuizzes);
    on<GetQuizByIdEvent>(_onGetQuizById);
    on<CreateQuizEvent>(_onCreateQuiz);
    on<UpdateQuizEvent>(_onUpdateQuiz);
    on<DeleteQuizEvent>(_onDeleteQuiz);
    on<AddQuestionEvent>(_onAddQuestion);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<DeleteQuestionEvent>(_onDeleteQuestion);
    on<ReorderQuestionsEvent>(_onReorderQuestions);
    on<StartQuizAttemptEvent>(_onStartQuizAttempt);
    on<SubmitQuizAttemptEvent>(_onSubmitQuizAttempt);
    on<GetQuizAttemptsEvent>(_onGetQuizAttempts);
    on<GetQuizAttemptDetailsEvent>(_onGetQuizAttemptDetails);
    on<RequestPublishEvent>(_onRequestPublish);
    on<GetPendingPublishRequestsEvent>(_onGetPendingPublishRequests);
    on<ApprovePublishRequestEvent>(_onApprovePublishRequest);
    on<RejectPublishRequestEvent>(_onRejectPublishRequest);
  }

  Future<void> _onGetAllQuizzes(
    GetAllQuizzesEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quizzes = await getAllQuizzesUseCase(
        search: event.search,
        limit: event.limit,
        offset: event.offset,
      );
      emit(QuizzesLoaded(quizzes));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to get quizzes: ${e.toString()}'));
    }
  }

  Future<void> _onGetQuizById(
    GetQuizByIdEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quiz = await getQuizByIdUseCase(event.id);
      emit(QuizLoaded(quiz));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to get quiz: ${e.toString()}'));
    }
  }

  Future<void> _onCreateQuiz(
    CreateQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quiz = await createQuizUseCase(
        title: event.title,
        description: event.description,
      );
      emit(QuizCreated(quiz));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to create quiz: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuiz(
    UpdateQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quiz = await updateQuizUseCase(
        id: event.id,
        title: event.title,
        description: event.description,
        isPublic: event.isPublic,
      );
      emit(QuizUpdated(quiz));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to update quiz: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuiz(
    DeleteQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await deleteQuizUseCase(event.id);
      emit(QuizDeleted());
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to delete quiz: ${e.toString()}'));
    }
  }

  Future<void> _onAddQuestion(
    AddQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final question = await addQuestionUseCase(
        quizId: event.quizId,
        kanjiId: event.kanjiId,
        questionText: event.questionText,
        questionType: event.questionType,
        options: event.options,
        correctAnswer: event.correctAnswer,
      );
      emit(QuestionAdded(question));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to add question: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuestion(
    UpdateQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final question = await updateQuestionUseCase(
        quizId: event.quizId,
        questionId: event.questionId,
        questionText: event.questionText,
        questionType: event.questionType,
        options: event.options,
        correctAnswer: event.correctAnswer,
      );
      emit(QuestionUpdated(question));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to update question: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteQuestion(
    DeleteQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await deleteQuestionUseCase(
        quizId: event.quizId,
        questionId: event.questionId,
      );
      emit(QuestionDeleted());
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to delete question: ${e.toString()}'));
    }
  }

  Future<void> _onReorderQuestions(
    ReorderQuestionsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await reorderQuestionsUseCase(
        quizId: event.quizId,
        questionOrders: event.questionOrders,
      );
      emit(QuestionsReordered());
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to reorder questions: ${e.toString()}'));
    }
  }

  Future<void> _onStartQuizAttempt(
    StartQuizAttemptEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempt = await startQuizAttemptUseCase(event.quizId);
      emit(QuizAttemptStarted(attempt));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to start quiz attempt: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitQuizAttempt(
    SubmitQuizAttemptEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempt = await submitQuizAttemptUseCase(
        attemptId: event.attemptId,
        answers: event.answers,
      );
      emit(QuizAttemptSubmitted(attempt));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to submit quiz attempt: ${e.toString()}'));
    }
  }

  Future<void> _onGetQuizAttempts(
    GetQuizAttemptsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempts = await getQuizAttemptsUseCase(event.quizId);
      emit(QuizAttemptsLoaded(attempts));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to get quiz attempts: ${e.toString()}'));
    }
  }

  Future<void> _onGetQuizAttemptDetails(
    GetQuizAttemptDetailsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempt = await getQuizAttemptDetailsUseCase(event.attemptId);
      emit(QuizAttemptDetailsLoaded(attempt));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to get attempt details: ${e.toString()}'));
    }
  }

  Future<void> _onRequestPublish(
    RequestPublishEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await requestPublishQuizUseCase(event.quizId, event.message);
      emit(PublishRequested());
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to request publish: ${e.toString()}'));
    }
  }

  Future<void> _onGetPendingPublishRequests(
    GetPendingPublishRequestsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final requests = await getPendingPublishRequestsUseCase();
      emit(PublishRequestsLoaded(requests));
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to get publish requests: ${e.toString()}'));
    }
  }

  Future<void> _onApprovePublishRequest(
    ApprovePublishRequestEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await approvePublishRequestUseCase(event.requestId);
      emit(PublishRequestApproved());
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to approve publish request: ${e.toString()}'));
    }
  }

  Future<void> _onRejectPublishRequest(
    RejectPublishRequestEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await rejectPublishRequestUseCase(event.requestId);
      emit(PublishRequestRejected());
    } on QuizException catch (e) {
      emit(QuizError(e.message));
    } catch (e) {
      emit(QuizError('Failed to reject publish request: ${e.toString()}'));
    }
  }
}
