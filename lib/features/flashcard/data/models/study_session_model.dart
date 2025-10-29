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
      sessionId: (json['sessionId'] as int?) ?? (json['id'] as int? ?? 0),
      deckId: json['deckId'] as int? ?? 0,
      deckName: json['deckName'] as String? ?? '',
      totalCards: json['totalCards'] as int? ?? 0,
      newCards: json['newCards'] as int? ?? 0,
      reviewCards: json['reviewCards'] as int? ?? 0,
      cardsReviewed: json['cardsReviewed'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
      accuracy: json['accuracy'] as int? ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      totalTime: json['totalTime'] as int?,
      cardsMastered: json['cardsMastered'] as int?,
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
