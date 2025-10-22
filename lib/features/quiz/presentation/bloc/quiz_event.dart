import 'package:equatable/equatable.dart';

/// Base event for Quiz BLoC
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

// ========== QUIZ LIST EVENTS ==========
/// Event to load all quizzes
class LoadQuizzesEvent extends QuizEvent {}

/// Event to load quiz history
class LoadQuizHistoryEvent extends QuizEvent {}

// ========== QUIZ SESSION EVENTS ==========
/// Event to start quiz
class StartQuizEvent extends QuizEvent {
  final String quizId;

  const StartQuizEvent(this.quizId);

  @override
  List<Object> get props => [quizId];
}

/// Event to load quiz questions
class LoadQuestionsEvent extends QuizEvent {
  final String quizId;

  const LoadQuestionsEvent(this.quizId);

  @override
  List<Object> get props => [quizId];
}

/// Event to answer question
class AnswerQuestionEvent extends QuizEvent {
  final String questionId;
  final String answer;

  const AnswerQuestionEvent({required this.questionId, required this.answer});

  @override
  List<Object> get props => [questionId, answer];
}

/// Event to move to next question
class NextQuestionEvent extends QuizEvent {}

/// Event to move to previous question
class PreviousQuestionEvent extends QuizEvent {}

/// Event to skip question
class SkipQuestionEvent extends QuizEvent {}

/// Event to complete quiz
class CompleteQuizEvent extends QuizEvent {
  final int timeSpent;

  const CompleteQuizEvent(this.timeSpent);

  @override
  List<Object> get props => [timeSpent];
}

/// Event to retry quiz
class RetryQuizEvent extends QuizEvent {
  final String quizId;

  const RetryQuizEvent(this.quizId);

  @override
  List<Object> get props => [quizId];
}

/// Event to view quiz result
class ViewQuizResultEvent extends QuizEvent {
  final String resultId;

  const ViewQuizResultEvent(this.resultId);

  @override
  List<Object> get props => [resultId];
}
