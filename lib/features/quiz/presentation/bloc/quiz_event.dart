import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

// Quiz CRUD Events
class GetAllQuizzesEvent extends QuizEvent {
  final String? search;
  final int? limit;
  final int? offset;

  const GetAllQuizzesEvent({this.search, this.limit, this.offset});

  @override
  List<Object?> get props => [search, limit, offset];
}

class GetQuizByIdEvent extends QuizEvent {
  final int id;

  const GetQuizByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateQuizEvent extends QuizEvent {
  final String title;
  final String? description;

  const CreateQuizEvent({required this.title, this.description});

  @override
  List<Object?> get props => [title, description];
}

class UpdateQuizEvent extends QuizEvent {
  final int id;
  final String? title;
  final String? description;
  final bool? isPublic;

  const UpdateQuizEvent({
    required this.id,
    this.title,
    this.description,
    this.isPublic,
  });

  @override
  List<Object?> get props => [id, title, description, isPublic];
}

class DeleteQuizEvent extends QuizEvent {
  final int id;

  const DeleteQuizEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// Question Management Events
class AddQuestionEvent extends QuizEvent {
  final int quizId;
  final int kanjiId;
  final String questionText;
  final String questionType;
  final List<String> options;
  final String correctAnswer;

  const AddQuestionEvent({
    required this.quizId,
    required this.kanjiId,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
  });

  @override
  List<Object?> get props => [
    quizId,
    kanjiId,
    questionText,
    questionType,
    options,
    correctAnswer,
  ];
}

class UpdateQuestionEvent extends QuizEvent {
  final int quizId;
  final int questionId;
  final String? questionText;
  final String? questionType;
  final List<String>? options;
  final String? correctAnswer;

  const UpdateQuestionEvent({
    required this.quizId,
    required this.questionId,
    this.questionText,
    this.questionType,
    this.options,
    this.correctAnswer,
  });

  @override
  List<Object?> get props => [
    quizId,
    questionId,
    questionText,
    questionType,
    options,
    correctAnswer,
  ];
}

class DeleteQuestionEvent extends QuizEvent {
  final int quizId;
  final int questionId;

  const DeleteQuestionEvent({required this.quizId, required this.questionId});

  @override
  List<Object?> get props => [quizId, questionId];
}

class ReorderQuestionsEvent extends QuizEvent {
  final int quizId;
  final List<Map<String, int>> questionOrders;

  const ReorderQuestionsEvent({
    required this.quizId,
    required this.questionOrders,
  });

  @override
  List<Object?> get props => [quizId, questionOrders];
}

// Quiz Attempt Events
class StartQuizAttemptEvent extends QuizEvent {
  final int quizId;

  const StartQuizAttemptEvent(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class SubmitQuizAttemptEvent extends QuizEvent {
  final int attemptId;
  final List<Map<String, dynamic>> answers;

  const SubmitQuizAttemptEvent({
    required this.attemptId,
    required this.answers,
  });

  @override
  List<Object?> get props => [attemptId, answers];
}

class GetQuizAttemptsEvent extends QuizEvent {
  final int quizId;

  const GetQuizAttemptsEvent(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class GetQuizAttemptDetailsEvent extends QuizEvent {
  final int attemptId;

  const GetQuizAttemptDetailsEvent(this.attemptId);

  @override
  List<Object?> get props => [attemptId];
}

// Publish Events
class RequestPublishEvent extends QuizEvent {
  final int quizId;
  final String? message;

  const RequestPublishEvent({required this.quizId, this.message});

  @override
  List<Object?> get props => [quizId, message];
}

class GetPendingPublishRequestsEvent extends QuizEvent {
  const GetPendingPublishRequestsEvent();
}

class ApprovePublishRequestEvent extends QuizEvent {
  final int requestId;

  const ApprovePublishRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectPublishRequestEvent extends QuizEvent {
  final int requestId;

  const RejectPublishRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
