import '../../domain/entities/quiz_result.dart';
import 'quiz_answer_model.dart';

/// Model for QuizResult with JSON serialization
class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.id,
    required super.userId,
    required super.quizId,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.incorrectAnswers,
    required super.skippedQuestions,
    required super.totalPoints,
    required super.earnedPoints,
    required super.scorePercentage,
    required super.timeSpent,
    required super.isPassed,
    required super.answers,
    required super.completedAt,
    required super.createdAt,
  });

  /// Create QuizResultModel from JSON
  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      quizId: json['quizId'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      incorrectAnswers: json['incorrectAnswers'] as int,
      skippedQuestions: json['skippedQuestions'] as int,
      totalPoints: json['totalPoints'] as int,
      earnedPoints: json['earnedPoints'] as int,
      scorePercentage: (json['scorePercentage'] as num).toDouble(),
      timeSpent: json['timeSpent'] as int,
      isPassed: json['isPassed'] as bool,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => QuizAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert QuizResultModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'skippedQuestions': skippedQuestions,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'scorePercentage': scorePercentage,
      'timeSpent': timeSpent,
      'isPassed': isPassed,
      'answers': answers
          .map((a) => QuizAnswerModel.fromEntity(a).toJson())
          .toList(),
      'completedAt': completedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert QuizResult entity to QuizResultModel
  factory QuizResultModel.fromEntity(QuizResult result) {
    return QuizResultModel(
      id: result.id,
      userId: result.userId,
      quizId: result.quizId,
      totalQuestions: result.totalQuestions,
      correctAnswers: result.correctAnswers,
      incorrectAnswers: result.incorrectAnswers,
      skippedQuestions: result.skippedQuestions,
      totalPoints: result.totalPoints,
      earnedPoints: result.earnedPoints,
      scorePercentage: result.scorePercentage,
      timeSpent: result.timeSpent,
      isPassed: result.isPassed,
      answers: result.answers,
      completedAt: result.completedAt,
      createdAt: result.createdAt,
    );
  }
}
