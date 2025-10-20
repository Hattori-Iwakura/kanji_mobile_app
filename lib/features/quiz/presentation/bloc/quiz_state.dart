import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/quiz_question_entity.dart';
import '../../domain/entities/quiz_attempt_entity.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

// Quiz CRUD States
class QuizzesLoaded extends QuizState {
  final List<QuizEntity> quizzes;

  const QuizzesLoaded(this.quizzes);

  @override
  List<Object?> get props => [quizzes];
}

class QuizLoaded extends QuizState {
  final QuizEntity quiz;

  const QuizLoaded(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizCreated extends QuizState {
  final QuizEntity quiz;

  const QuizCreated(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizUpdated extends QuizState {
  final QuizEntity quiz;

  const QuizUpdated(this.quiz);

  @override
  List<Object?> get props => [quiz];
}

class QuizDeleted extends QuizState {}

// Question Management States
class QuestionAdded extends QuizState {
  final QuizQuestionEntity question;

  const QuestionAdded(this.question);

  @override
  List<Object?> get props => [question];
}

class QuestionUpdated extends QuizState {
  final QuizQuestionEntity question;

  const QuestionUpdated(this.question);

  @override
  List<Object?> get props => [question];
}

class QuestionDeleted extends QuizState {}

class QuestionsReordered extends QuizState {}

// Quiz Attempt States
class QuizAttemptStarted extends QuizState {
  final QuizAttemptEntity attempt;

  const QuizAttemptStarted(this.attempt);

  @override
  List<Object?> get props => [attempt];
}

class QuizAttemptSubmitted extends QuizState {
  final QuizAttemptEntity attempt;

  const QuizAttemptSubmitted(this.attempt);

  @override
  List<Object?> get props => [attempt];
}

class QuizAttemptsLoaded extends QuizState {
  final List<QuizAttemptEntity> attempts;

  const QuizAttemptsLoaded(this.attempts);

  @override
  List<Object?> get props => [attempts];
}

class QuizAttemptDetailsLoaded extends QuizState {
  final QuizAttemptEntity attempt;

  const QuizAttemptDetailsLoaded(this.attempt);

  @override
  List<Object?> get props => [attempt];
}

// Publish States
class PublishRequested extends QuizState {}

class PublishRequestsLoaded extends QuizState {
  final List<dynamic> requests;

  const PublishRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class PublishRequestApproved extends QuizState {}

class PublishRequestRejected extends QuizState {}

// Error State
class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
