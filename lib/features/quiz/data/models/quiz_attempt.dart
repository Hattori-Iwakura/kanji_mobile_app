import '../../domain/entities/quiz_attempt_entity.dart';

class QuizAttempt extends QuizAttemptEntity {
  final Map<String, dynamic>? answers;

  const QuizAttempt({
    required super.id,
    required super.quizId,
    required super.userId,
    required super.score,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.startedAt,
    super.completedAt,
    required super.status,
    this.answers,
  });

  bool get isCompleted => completedAt != null;

  int get percentage =>
      totalQuestions > 0 ? ((score / totalQuestions) * 100).round() : 0;

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as int,
      quizId: json['quizId'] as int,
      userId: json['userId'] as int,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      status:
          json['status'] as String? ??
          (json['completedAt'] != null ? 'completed' : 'in_progress'),
      answers: json['answers'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
      'answers': answers,
    };
  }

  QuizAttemptEntity toEntity() {
    return QuizAttemptEntity(
      id: id,
      quizId: quizId,
      userId: userId,
      score: score,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      startedAt: startedAt,
      completedAt: completedAt,
      status: status,
    );
  }

  @override
  List<Object?> get props => [...super.props, answers];
}
