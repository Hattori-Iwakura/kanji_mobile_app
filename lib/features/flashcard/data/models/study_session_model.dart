import '../../domain/entities/study_session.dart';

class StudySessionModel extends StudySession {
  const StudySessionModel({
    required super.sessionId,
    required super.deckId,
    required super.deckName,
    required super.totalCards,
    required super.newCards,
    required super.reviewCards,
    required super.cardsReviewed,
    required super.correctAnswers,
    required super.incorrectAnswers,
    required super.accuracy,
    required super.startedAt,
    super.completedAt,
    super.totalTime,
    super.cardsMastered,
  });

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      sessionId:
          (json['sessionId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      deckId: (json['deckId'] as num?)?.toInt() ?? 0,
      deckName: json['deckName'] as String? ?? '',
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      newCards: (json['newCards'] as num?)?.toInt() ?? 0,
      reviewCards: (json['reviewCards'] as num?)?.toInt() ?? 0,
      cardsReviewed: (json['cardsReviewed'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      incorrectAnswers: (json['incorrectAnswers'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      totalTime: (json['totalTime'] as num?)?.toInt(),
      cardsMastered: (json['cardsMastered'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'deckId': deckId,
      'deckName': deckName,
      'totalCards': totalCards,
      'newCards': newCards,
      'reviewCards': reviewCards,
      'cardsReviewed': cardsReviewed,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'accuracy': accuracy,
      'startedAt': startedAt.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      if (totalTime != null) 'totalTime': totalTime,
      if (cardsMastered != null) 'cardsMastered': cardsMastered,
    };
  }
}
