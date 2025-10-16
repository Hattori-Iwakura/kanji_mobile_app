import 'package:equatable/equatable.dart';

enum ProgressStatus {
  newKanji('new'),
  learning('learning'),
  known('known'),
  mastered('mastered');

  final String value;
  const ProgressStatus(this.value);

  static ProgressStatus fromString(String value) {
    return ProgressStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProgressStatus.newKanji,
    );
  }
}

class KanjiProgress extends Equatable {
  final int userId;
  final int kanjiId;
  final ProgressStatus status;
  final int timesReviewed;
  final int timesCorrect;
  final DateTime? lastReviewed;
  final DateTime? firstLearned;
  final DateTime? masteredAt;

  const KanjiProgress({
    required this.userId,
    required this.kanjiId,
    required this.status,
    required this.timesReviewed,
    required this.timesCorrect,
    this.lastReviewed,
    this.firstLearned,
    this.masteredAt,
  });

  // Calculate accuracy percentage
  double get accuracy {
    if (timesReviewed == 0) return 0.0;
    return (timesCorrect / timesReviewed) * 100;
  }

  // Check if needs review (e.g., not reviewed in 24 hours)
  bool get needsReview {
    if (lastReviewed == null) return true;
    final hoursSinceReview = DateTime.now().difference(lastReviewed!).inHours;

    switch (status) {
      case ProgressStatus.newKanji:
        return hoursSinceReview >= 1; // Review after 1 hour
      case ProgressStatus.learning:
        return hoursSinceReview >= 4; // Review after 4 hours
      case ProgressStatus.known:
        return hoursSinceReview >= 24; // Review after 1 day
      case ProgressStatus.mastered:
        return hoursSinceReview >= 168; // Review after 1 week
    }
  }

  @override
  List<Object?> get props => [
    userId,
    kanjiId,
    status,
    timesReviewed,
    timesCorrect,
    lastReviewed,
    firstLearned,
    masteredAt,
  ];
}
