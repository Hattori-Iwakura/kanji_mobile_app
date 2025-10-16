import 'package:equatable/equatable.dart';

class FlashcardReview extends Equatable {
  final int id;
  final int cardId;
  final int sessionId;
  final int rating;
  final int timeSpent;
  final DateTime createdAt;
  final DateTime sessionDate;

  const FlashcardReview({
    required this.id,
    required this.cardId,
    required this.sessionId,
    required this.rating,
    required this.timeSpent,
    required this.createdAt,
    required this.sessionDate,
  });

  @override
  List<Object?> get props => [
    id,
    cardId,
    sessionId,
    rating,
    timeSpent,
    createdAt,
    sessionDate,
  ];
}
