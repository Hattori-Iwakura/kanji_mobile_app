import '../../domain/entities/question.dart';

abstract class QuizEvent {}

// Quiz CRUD Events
class LoadQuizzesEvent extends QuizEvent {
  final String? search;
  final int? limit;
  final int? offset;

  LoadQuizzesEvent({this.search, this.limit, this.offset});
}

class LoadQuizDetailEvent extends QuizEvent {
  final int quizId;

  LoadQuizDetailEvent(this.quizId);
}

class CreateQuizEvent extends QuizEvent {
  final String title;
  final String? description;

  CreateQuizEvent({required this.title, this.description});
}

class UpdateQuizEvent extends QuizEvent {
  final int quizId;
  final String? title;
  final String? description;
  final bool? isPublic;

  UpdateQuizEvent({
    required this.quizId,
    this.title,
    this.description,
    this.isPublic,
  });
}

class DeleteQuizEvent extends QuizEvent {
  final int quizId;

  DeleteQuizEvent(this.quizId);
}

// Question Management Events
class AddQuestionEvent extends QuizEvent {
  final int quizId;
  final QuestionType type;
  final String questionText;
  final String correctAnswer;
  final List<String>? options;
  final String? explanation;
  final int? points;
  final List<String>? meanings;

  AddQuestionEvent({
    required this.quizId,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    this.explanation,
    this.points,
    this.meanings,
  });
}

class UpdateQuestionEvent extends QuizEvent {
  final int quizId;
  final int questionId;
  final QuestionType? type;
  final String? questionText;
  final String? correctAnswer;
  final List<String>? options;
  final String? explanation;
  final int? points;
  final List<String>? meanings;

  UpdateQuestionEvent({
    required this.quizId,
    required this.questionId,
    this.type,
    this.questionText,
    this.correctAnswer,
    this.options,
    this.explanation,
    this.points,
    this.meanings,
  });
}

class DeleteQuestionEvent extends QuizEvent {
  final int quizId;
  final int questionId;

  DeleteQuestionEvent({required this.quizId, required this.questionId});
}

// Quiz Attempt Events
class StartQuizAttemptEvent extends QuizEvent {
  final int quizId;

  StartQuizAttemptEvent(this.quizId);
}

class SubmitQuizAttemptEvent extends QuizEvent {
  final int attemptId;
  final List<Map<String, dynamic>> answers;
  final int? timeSpent;

  SubmitQuizAttemptEvent({
    required this.attemptId,
    required this.answers,
    this.timeSpent,
  });
}

class LoadQuizAttemptsEvent extends QuizEvent {
  final int quizId;

  LoadQuizAttemptsEvent(this.quizId);
}

class LoadQuizAttemptDetailsEvent extends QuizEvent {
  final int attemptId;

  LoadQuizAttemptDetailsEvent(this.attemptId);
}
