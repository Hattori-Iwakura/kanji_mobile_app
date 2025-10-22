import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_quizzes.dart';
import '../../domain/usecases/get_quiz_questions.dart';
import '../../domain/usecases/submit_quiz_answer.dart';
import '../../domain/usecases/complete_quiz.dart';
import '../../domain/usecases/get_quiz_history.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

/// BLoC for managing quiz state
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetAllQuizzes getAllQuizzes;
  final GetQuizQuestions getQuizQuestions;
  final SubmitQuizAnswer submitQuizAnswer;
  final CompleteQuiz completeQuiz;
  final GetQuizHistory getQuizHistory;
  final QuizRepository repository;

  QuizBloc({
    required this.getAllQuizzes,
    required this.getQuizQuestions,
    required this.submitQuizAnswer,
    required this.completeQuiz,
    required this.getQuizHistory,
    required this.repository,
  }) : super(QuizInitial()) {
    on<LoadQuizzesEvent>(_onLoadQuizzes);
    on<LoadQuizHistoryEvent>(_onLoadQuizHistory);
    on<StartQuizEvent>(_onStartQuiz);
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<NextQuestionEvent>(_onNextQuestion);
    on<PreviousQuestionEvent>(_onPreviousQuestion);
    on<SkipQuestionEvent>(_onSkipQuestion);
    on<CompleteQuizEvent>(_onCompleteQuiz);
    on<RetryQuizEvent>(_onRetryQuiz);
    on<ViewQuizResultEvent>(_onViewQuizResult);
  }

  Future<void> _onLoadQuizzes(
    LoadQuizzesEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await getAllQuizzes();

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (quizzes) => emit(QuizzesLoaded(quizzes)),
    );
  }

  Future<void> _onLoadQuizHistory(
    LoadQuizHistoryEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await getQuizHistory();

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (history) => emit(QuizHistoryLoaded(history)),
    );
  }

  Future<void> _onStartQuiz(
    StartQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    // Start quiz session on backend
    final startResult = await repository.startQuiz(event.quizId);

    await startResult.fold(
      (failure) async => emit(QuizError(failure.message)),
      (sessionId) async {
        // Load questions
        final questionsResult = await getQuizQuestions(event.quizId);

        questionsResult.fold((failure) => emit(QuizError(failure.message)), (
          questions,
        ) {
          if (questions.isEmpty) {
            emit(const QuizError('No questions found for this quiz'));
          } else {
            emit(
              QuizSessionActive(
                quizId: event.quizId,
                questions: questions,
                currentIndex: 0,
                userAnswers: {},
                answerResults: {},
                startTime: DateTime.now(),
              ),
            );
          }
        });
      },
    );
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await getQuizQuestions(event.quizId);

    result.fold((failure) => emit(QuizError(failure.message)), (questions) {
      if (questions.isEmpty) {
        emit(const QuizError('No questions found for this quiz'));
      } else {
        emit(
          QuizSessionActive(
            quizId: event.quizId,
            questions: questions,
            currentIndex: 0,
            userAnswers: {},
            answerResults: {},
            startTime: DateTime.now(),
          ),
        );
      }
    });
  }

  Future<void> _onAnswerQuestion(
    AnswerQuestionEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizSessionActive) return;

    final currentState = state as QuizSessionActive;

    // Submit answer to backend
    final result = await submitQuizAnswer(
      quizId: currentState.quizId,
      questionId: event.questionId,
      answer: event.answer,
    );

    result.fold((failure) => emit(QuizError(failure.message)), (isCorrect) {
      // Update answers map
      final updatedAnswers = Map<String, String>.from(currentState.userAnswers);
      updatedAnswers[event.questionId] = event.answer;

      // Update results map
      final updatedResults = Map<String, bool>.from(currentState.answerResults);
      updatedResults[event.questionId] = isCorrect;

      // Update state
      emit(
        currentState.copyWith(
          userAnswers: updatedAnswers,
          answerResults: updatedResults,
        ),
      );
    });
  }

  void _onNextQuestion(NextQuestionEvent event, Emitter<QuizState> emit) {
    if (state is! QuizSessionActive) return;

    final currentState = state as QuizSessionActive;

    if (!currentState.isLastQuestion) {
      emit(currentState.copyWith(currentIndex: currentState.currentIndex + 1));
    }
  }

  void _onPreviousQuestion(
    PreviousQuestionEvent event,
    Emitter<QuizState> emit,
  ) {
    if (state is! QuizSessionActive) return;

    final currentState = state as QuizSessionActive;

    if (!currentState.isFirstQuestion) {
      emit(currentState.copyWith(currentIndex: currentState.currentIndex - 1));
    }
  }

  void _onSkipQuestion(SkipQuestionEvent event, Emitter<QuizState> emit) {
    if (state is! QuizSessionActive) return;

    final currentState = state as QuizSessionActive;

    // Just move to next question without answering
    if (!currentState.isLastQuestion) {
      emit(currentState.copyWith(currentIndex: currentState.currentIndex + 1));
    }
  }

  Future<void> _onCompleteQuiz(
    CompleteQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is! QuizSessionActive) return;

    final currentState = state as QuizSessionActive;

    emit(QuizLoading());

    final result = await completeQuiz(
      quizId: currentState.quizId,
      timeSpent: event.timeSpent,
    );

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (quizResult) => emit(QuizCompleted(quizResult)),
    );
  }

  Future<void> _onRetryQuiz(
    RetryQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await repository.retryQuiz(event.quizId);

    await result.fold((failure) async => emit(QuizError(failure.message)), (
      _,
    ) async {
      // Reload questions
      add(LoadQuestionsEvent(event.quizId));
    });
  }

  Future<void> _onViewQuizResult(
    ViewQuizResultEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await repository.getQuizResultById(event.resultId);

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (quizResult) => emit(QuizCompleted(quizResult)),
    );
  }
}
