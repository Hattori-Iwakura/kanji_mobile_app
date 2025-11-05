import '../../domain/entities/active_session.dart';

class ActiveSessionModel extends ActiveSession {
  ActiveSessionModel({
    required super.sessionId,
    required super.deckId,
    required super.totalCards,
    required super.cardsReviewed,
    required super.cardsRemaining,
    required super.startedAt,
    required super.accuracy,
  });

  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      sessionId: (json['sessionId'] as num).toInt(),
      deckId: (json['deckId'] as num).toInt(),
      totalCards: (json['totalCards'] as num).toInt(),
      cardsReviewed: (json['cardsReviewed'] as num).toInt(),
      cardsRemaining: (json['cardsRemaining'] as num).toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'deckId': deckId,
      'totalCards': totalCards,
      'cardsReviewed': cardsReviewed,
      'cardsRemaining': cardsRemaining,
      'startedAt': startedAt.toIso8601String(),
      'accuracy': accuracy,
    };
  }
}
