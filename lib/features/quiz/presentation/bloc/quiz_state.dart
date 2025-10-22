import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_result.dart';

/// Base state for Quiz BLoC
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuizInitial extends QuizState {}

/// Loading state
class QuizLoading extends QuizState {}

// ========== QUIZ LIST STATES ==========
/// State when quizzes are loaded
class QuizzesLoaded extends QuizState {
  final List<Quiz> quizzes;

  const QuizzesLoaded(this.quizzes);

  @override
  List<Object> get props => [quizzes];

  /// Check if user has any quizzes
  bool get hasQuizzes => quizzes.isNotEmpty;

  /// Get quizzes by difficulty
  List<Quiz> getByDifficulty(String difficulty) {
    return quizzes
        .where((q) => q.difficulty.toUpperCase() == difficulty.toUpperCase())
        .toList();
  }
}

/// State when quiz history is loaded
class QuizHistoryLoaded extends QuizState {
  final List<QuizResult> history;

  const QuizHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];

  /// Check if user has history
  bool get hasHistory => history.isNotEmpty;

  /// Get average score
  double get averageScore {
    if (history.isEmpty) return 0.0;
    final total = history.fold<double>(
      0.0,
      (sum, result) => sum + result.scorePercentage,
    );
    return total / history.length;
  }

  /// Get total quizzes completed
  int get totalCompleted => history.length;

  /// Get total quizzes passed
  int get totalPassed => history.where((r) => r.isPassed).length;
}

// ========== QUIZ SESSION STATES ==========
/// State when quiz session is active
class QuizSessionActive extends QuizState {
  final String quizId;
  final List<Question> questions;
  final int currentIndex;
  final Map<String, String> userAnswers; // questionId -> answer
  final Map<String, bool> answerResults; // questionId -> isCorrect
  final DateTime startTime;

  const QuizSessionActive({
    required this.quizId,
    required this.questions,
    required this.currentIndex,
    required this.userAnswers,
    required this.answerResults,
    required this.startTime,
  });

  @override
  List<Object> get props => [
    quizId,
    questions,
    currentIndex,
    userAnswers,
    answerResults,
    startTime,
  ];

  /// Get current question
  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  /// Check if on last question
  bool get isLastQuestion => currentIndex == questions.length - 1;

  /// Check if on first question
  bool get isFirstQuestion => currentIndex == 0;

  /// Check if all questions answered
  bool get allAnswered => userAnswers.length == questions.length;

  /// Get progress percentage
  double get progressPercentage {
    if (questions.isEmpty) return 0.0;
    return (currentIndex / questions.length) * 100;
  }

  /// Get number of answered questions
  int get answeredCount => userAnswers.length;

  /// Get number of unanswered questions
  int get unansweredCount => questions.length - userAnswers.length;

  /// Check if current question is answered
  bool get currentQuestionAnswered {
    final current = currentQuestion;
    if (current == null) return false;
    return userAnswers.containsKey(current.id);
  }

  /// Get user's answer for current question
  String? get currentAnswer {
    final current = currentQuestion;
    if (current == null) return null;
    return userAnswers[current.id];
  }

  /// Get elapsed time in seconds
  int get elapsedTime => DateTime.now().difference(startTime).inSeconds;

  /// Copy with new values
  QuizSessionActive copyWith({
    String? quizId,
    List<Question>? questions,
    int? currentIndex,
    Map<String, String>? userAnswers,
    Map<String, bool>? answerResults,
    DateTime? startTime,
  }) {
    return QuizSessionActive(
      quizId: quizId ?? this.quizId,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      answerResults: answerResults ?? this.answerResults,
      startTime: startTime ?? this.startTime,
    );
  }
}

/// State when answer is submitted and checked
class AnswerChecked extends QuizState {
  final bool isCorrect;
  final String correctAnswer;
  final String? explanation;

  const AnswerChecked({
    required this.isCorrect,
    required this.correctAnswer,
    this.explanation,
  });

  @override
  List<Object?> get props => [isCorrect, correctAnswer, explanation];
}

/// State when quiz is completed
class QuizCompleted extends QuizState {
  final QuizResult result;

  const QuizCompleted(this.result);

  @override
  List<Object> get props => [result];
}

/// Error state
class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object> get props => [message];
}
