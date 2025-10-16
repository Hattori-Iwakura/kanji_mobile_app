import '../../domain/entities/flashcard_review.dart';

class FlashcardReviewModel extends FlashcardReview {
  const FlashcardReviewModel({
    required super.id,
    required super.cardId,
    required super.sessionId,
    required super.rating,
    required super.timeSpent,
    required super.createdAt,
    required super.sessionDate,
  });

  factory FlashcardReviewModel.fromJson(Map<String, dynamic> json) {
    final session = json['Session'] as Map<String, dynamic>?;
    return FlashcardReviewModel(
      id: json['id'] as int,
      cardId: json['card_id'] as int,
      sessionId: json['session_id'] as int,
      rating: json['rating'] as int,
      timeSpent: json['time_spent'] as int,
      createdAt: DateTime.parse(json['create_at'] as String),
      sessionDate: session != null
          ? DateTime.parse(session['create_at'] as String)
          : DateTime.parse(json['create_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_id': cardId,
      'session_id': sessionId,
      'rating': rating,
      'time_spent': timeSpent,
      'create_at': createdAt.toIso8601String(),
      'Session': {'create_at': sessionDate.toIso8601String()},
    };
  }
}
