import '../../domain/entities/flashcard_progress.dart';

class FlashcardProgressModel extends FlashcardProgress {
  const FlashcardProgressModel({
    required super.totalSessions,
    required super.totalStudyTime,
    required super.period,
  });

  factory FlashcardProgressModel.fromJson(Map<String, dynamic> json) {
    return FlashcardProgressModel(
      totalSessions: json['totalSessions'] as int? ?? 0,
      totalStudyTime: json['totalStudyTime'] as int? ?? 0,
      period: json['period'] as String? ?? '7d',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalStudyTime': totalStudyTime,
      'period': period,
    };
  }
}
