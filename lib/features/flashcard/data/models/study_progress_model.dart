import '../../domain/entities/study_progress.dart';

/// Model for StudyProgress with JSON serialization
class StudyProgressModel extends StudyProgress {
  const StudyProgressModel({
    required super.id,
    required super.userId,
    required super.deckId,
    required super.cardsStudied,
    required super.cardsCorrect,
    required super.cardsIncorrect,
    required super.studyDuration,
    required super.sessionDate,
    required super.createdAt,
  });

  /// Create model from JSON
  factory StudyProgressModel.fromJson(Map<String, dynamic> json) {
    return StudyProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deckId: json['deckId'] as String,
      cardsStudied: json['cardsStudied'] as int,
      cardsCorrect: json['cardsCorrect'] as int,
      cardsIncorrect: json['cardsIncorrect'] as int,
      studyDuration: json['studyDuration'] as int,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deckId': deckId,
      'cardsStudied': cardsStudied,
      'cardsCorrect': cardsCorrect,
      'cardsIncorrect': cardsIncorrect,
      'studyDuration': studyDuration,
      'sessionDate': sessionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert model to entity
  StudyProgress toEntity() {
    return StudyProgress(
      id: id,
      userId: userId,
      deckId: deckId,
      cardsStudied: cardsStudied,
      cardsCorrect: cardsCorrect,
      cardsIncorrect: cardsIncorrect,
      studyDuration: studyDuration,
      sessionDate: sessionDate,
      createdAt: createdAt,
    );
  }
}
