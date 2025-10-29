import '../../domain/entities/quiz.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_attempt.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

// Quiz List States
class QuizzesLoaded extends QuizState {
  final List<Quiz> quizzes;

  QuizzesLoaded({required this.quizzes});
}

// Quiz Detail States
class QuizDetailLoaded extends QuizState {
  final Quiz quiz;

  QuizDetailLoaded({required this.quiz});
}

class QuizCreated extends QuizState {
  final Quiz quiz;

  QuizCreated({required this.quiz});
}

class QuizUpdated extends QuizState {
  final Quiz quiz;

  QuizUpdated({required this.quiz});
}

class QuizDeleted extends QuizState {}

// Question States
class QuestionAdded extends QuizState {
  final Question question;

  QuestionAdded({required this.question});
}

class QuestionUpdated extends QuizState {
  final Question question;

  QuestionUpdated({required this.question});
}

class QuestionDeleted extends QuizState {}

// Quiz Attempt States
class QuizAttemptStarted extends QuizState {
  final QuizAttempt attempt;

  QuizAttemptStarted({required this.attempt});
}

class QuizAttemptSubmitted extends QuizState {
  final QuizAttempt attempt;

  QuizAttemptSubmitted({required this.attempt});
}

class QuizAttemptsLoaded extends QuizState {
  final List<QuizAttempt> attempts;

  QuizAttemptsLoaded({required this.attempts});
}

class QuizAttemptDetailsLoaded extends QuizState {
  final QuizAttempt attempt;

  QuizAttemptDetailsLoaded({required this.attempt});
}

// Error State
class QuizError extends QuizState {
  final String message;

  QuizError({required this.message});
}
