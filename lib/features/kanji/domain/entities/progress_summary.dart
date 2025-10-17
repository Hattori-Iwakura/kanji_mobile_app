import 'package:equatable/equatable.dart';

class ProgressSummary extends Equatable {
  final int newCount;
  final int learningCount;
  final int knownCount;
  final int masteredCount;

  const ProgressSummary({
    required this.newCount,
    required this.learningCount,
    required this.knownCount,
    required this.masteredCount,
  });

  // Get total kanji being tracked
  int get totalCount => newCount + learningCount + knownCount + masteredCount;

  // Get total kanji learned (excluding new)
  int get totalKanjiLearned => learningCount + knownCount + masteredCount;

  // Calculate completion percentage
  double get completionPercentage {
    if (totalCount == 0) return 0.0;
    return ((knownCount + masteredCount) / totalCount) * 100;
  }

  // Get learning percentage (excluding new)
  double get learningPercentage {
    if (totalCount == 0) return 0.0;
    return ((learningCount + knownCount + masteredCount) / totalCount) * 100;
  }

  @override
  List<Object?> get props => [
    newCount,
    learningCount,
    knownCount,
    masteredCount,
  ];
}
