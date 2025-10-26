import '../../domain/entities/quiz_progress.dart';

class QuizProgressModel extends QuizProgress {
  const QuizProgressModel({
    required super.totalAttempts,
    required super.bestScore,
    required super.period,
  });

  factory QuizProgressModel.fromJson(Map<String, dynamic> json) {
    return QuizProgressModel(
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
      period: json['period'] as String? ?? '7d',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAttempts': totalAttempts,
      'bestScore': bestScore,
      'period': period,
    };
  }
}
