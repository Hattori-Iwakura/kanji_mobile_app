import '../../domain/entities/progress_summary.dart';

class ProgressSummaryModel extends ProgressSummary {
  const ProgressSummaryModel({
    required super.newCount,
    required super.learningCount,
    required super.knownCount,
    required super.masteredCount,
  });

  factory ProgressSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProgressSummaryModel(
      newCount: json['new'] as int? ?? 0,
      learningCount: json['learning'] as int? ?? 0,
      knownCount: json['known'] as int? ?? 0,
      masteredCount: json['mastered'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new': newCount,
      'learning': learningCount,
      'known': knownCount,
      'mastered': masteredCount,
    };
  }
}
