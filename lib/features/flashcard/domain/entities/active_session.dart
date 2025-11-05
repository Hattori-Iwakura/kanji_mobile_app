class ActiveSession {
  final int sessionId;
  final int deckId;
  final int totalCards;
  final int cardsReviewed;
  final int cardsRemaining;
  final DateTime startedAt;
  final double accuracy;

  ActiveSession({
    required this.sessionId,
    required this.deckId,
    required this.totalCards,
    required this.cardsReviewed,
    required this.cardsRemaining,
    required this.startedAt,
    required this.accuracy,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      sessionId: json['sessionId'] as int,
      deckId: json['deckId'] as int,
      totalCards: json['totalCards'] as int,
      cardsReviewed: json['cardsReviewed'] as int,
      cardsRemaining: json['cardsRemaining'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }

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

  double get progressPercentage =>
      totalCards > 0 ? (cardsReviewed / totalCards) * 100 : 0;
}
