import '../../domain/entities/kanji_progress.dart';

class KanjiProgressModel extends KanjiProgress {
  const KanjiProgressModel({
    required super.userId,
    required super.kanjiId,
    required super.status,
    required super.timesReviewed,
    required super.timesCorrect,
    super.lastReviewed,
    super.firstLearned,
    super.masteredAt,
  });

  factory KanjiProgressModel.fromJson(Map<String, dynamic> json) {
    return KanjiProgressModel(
      userId: json['user_id'] as int,
      kanjiId: json['kanji_id'] as int,
      status: ProgressStatus.fromString(json['status'] as String),
      timesReviewed: json['times_reviewed'] as int,
      timesCorrect: json['times_correct'] as int,
      lastReviewed: json['last_reviewed'] != null
          ? DateTime.parse(json['last_reviewed'] as String)
          : null,
      firstLearned: json['first_learned'] != null
          ? DateTime.parse(json['first_learned'] as String)
          : null,
      masteredAt: json['mastered_at'] != null
          ? DateTime.parse(json['mastered_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'kanji_id': kanjiId,
      'status': status.value,
      'times_reviewed': timesReviewed,
      'times_correct': timesCorrect,
      'last_reviewed': lastReviewed?.toIso8601String(),
      'first_learned': firstLearned?.toIso8601String(),
      'mastered_at': masteredAt?.toIso8601String(),
    };
  }
}
