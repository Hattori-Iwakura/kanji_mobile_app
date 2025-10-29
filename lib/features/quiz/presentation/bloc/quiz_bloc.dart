import 'package:flutter_bloc/flutter_bloc.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';
import '../../domain/usecases/get_quizzes.dart';
import '../../domain/usecases/get_quiz_detail.dart';
import '../../domain/usecases/create_quiz.dart';
import '../../domain/usecases/update_quiz.dart';
import '../../domain/usecases/delete_quiz.dart';
import '../../domain/usecases/add_question.dart';
import '../../domain/usecases/update_question.dart';
import '../../domain/usecases/delete_question.dart';
import '../../domain/usecases/start_quiz_attempt.dart';
import '../../domain/usecases/submit_quiz_attempt.dart';
import '../../domain/usecases/get_quiz_attempts.dart';
import '../../domain/usecases/get_quiz_attempt_details.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuizzesUseCase getQuizzesUseCase;
  final GetQuizDetailUseCase getQuizDetailUseCase;
  final CreateQuizUseCase createQuizUseCase;
  final UpdateQuizUseCase updateQuizUseCase;
  final DeleteQuizUseCase deleteQuizUseCase;
  final AddQuestionUseCase addQuestionUseCase;
  final UpdateQuestionUseCase updateQuestionUseCase;
  final DeleteQuestionUseCase deleteQuestionUseCase;
  final StartQuizAttemptUseCase startQuizAttemptUseCase;
  final SubmitQuizAttemptUseCase submitQuizAttemptUseCase;
  final GetQuizAttemptsUseCase getQuizAttemptsUseCase;
  final GetQuizAttemptDetailsUseCase getQuizAttemptDetailsUseCase;

  QuizBloc({
    required this.getQuizzesUseCase,
    required this.getQuizDetailUseCase,
    required this.createQuizUseCase,
    required this.updateQuizUseCase,
    required this.deleteQuizUseCase,
    required this.addQuestionUseCase,
    required this.updateQuestionUseCase,
    required this.deleteQuestionUseCase,
    required this.startQuizAttemptUseCase,
    required this.submitQuizAttemptUseCase,
    required this.getQuizAttemptsUseCase,
    required this.getQuizAttemptDetailsUseCase,
  }) : super(QuizInitial()) {
    on<LoadQuizzesEvent>(_onLoadQuizzes);
    on<LoadQuizDetailEvent>(_onLoadQuizDetail);
    on<CreateQuizEvent>(_onCreateQuiz);
    on<UpdateQuizEvent>(_onUpdateQuiz);
    on<DeleteQuizEvent>(_onDeleteQuiz);
    on<AddQuestionEvent>(_onAddQuestion);
    on<UpdateQuestionEvent>(_onUpdateQuestion);
    on<DeleteQuestionEvent>(_onDeleteQuestion);
    on<StartQuizAttemptEvent>(_onStartQuizAttempt);
    on<SubmitQuizAttemptEvent>(_onSubmitQuizAttempt);
    on<LoadQuizAttemptsEvent>(_onLoadQuizAttempts);
    on<LoadQuizAttemptDetailsEvent>(_onLoadQuizAttemptDetails);
  }

  Future<void> _onLoadQuizzes(
    LoadQuizzesEvent event,
    Emitter<QuizState> emit,
  ) async {
    print('🔍 BLOC - _onLoadQuizzes called');
    emit(QuizLoading());
    try {
      print('🔍 BLOC - calling getQuizzesUseCase');
      final quizzes = await getQuizzesUseCase(
        search: event.search,
        limit: event.limit,
        offset: event.offset,
      );
      
      print('🔍 BLOC - quizzes type: ${quizzes.runtimeType}');
      print('🔍 BLOC - quizzes length: ${quizzes.length}');
      print('🔍 BLOC - emitting QuizzesLoaded');
      
      emit(QuizzesLoaded(quizzes: quizzes));
      
      print('🔍 BLOC - QuizzesLoaded emitted successfully');
    } catch (e, stack) {
      print('❌ BLOC - Error: $e');
      print('❌ BLOC - Stack: $stack');
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onLoadQuizDetail(
    LoadQuizDetailEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quiz = await getQuizDetailUseCase(event.quizId);
      emit(QuizDetailLoaded(quiz: quiz));
    } catch (e) {
      emit(QuizError(message: e.toString()));
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
      emit(QuizCreated(quiz: quiz));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onUpdateQuiz(
    UpdateQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final quiz = await updateQuizUseCase(
        quizId: event.quizId,
        title: event.title,
        description: event.description,
        isPublic: event.isPublic,
      );
      emit(QuizUpdated(quiz: quiz));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onDeleteQuiz(
    DeleteQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      await deleteQuizUseCase(event.quizId);
      emit(QuizDeleted());
    } catch (e) {
      emit(QuizError(message: e.toString()));
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
        type: event.type,
        questionText: event.questionText,
        correctAnswer: event.correctAnswer,
        options: event.options,
        explanation: event.explanation,
        points: event.points,
        meanings: event.meanings,
      );
      emit(QuestionAdded(question: question));
    } catch (e) {
      emit(QuizError(message: e.toString()));
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
        type: event.type,
        questionText: event.questionText,
        correctAnswer: event.correctAnswer,
        options: event.options,
        explanation: event.explanation,
        points: event.points,
        meanings: event.meanings,
      );
      emit(QuestionUpdated(question: question));
    } catch (e) {
      emit(QuizError(message: e.toString()));
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
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onStartQuizAttempt(
    StartQuizAttemptEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempt = await startQuizAttemptUseCase(event.quizId);
      emit(QuizAttemptStarted(attempt: attempt));
    } catch (e) {
      emit(QuizError(message: e.toString()));
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
        timeSpent: event.timeSpent,
      );
      emit(QuizAttemptSubmitted(attempt: attempt));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onLoadQuizAttempts(
    LoadQuizAttemptsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempts = await getQuizAttemptsUseCase(event.quizId);
      emit(QuizAttemptsLoaded(attempts: attempts));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> _onLoadQuizAttemptDetails(
    LoadQuizAttemptDetailsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());
    try {
      final attempt = await getQuizAttemptDetailsUseCase(event.attemptId);
      emit(QuizAttemptDetailsLoaded(attempt: attempt));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }
}
