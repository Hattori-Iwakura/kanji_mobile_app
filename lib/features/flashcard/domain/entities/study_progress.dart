import 'package:equatable/equatable.dart';

/// Entity representing a user's progress in a study session
class StudyProgress extends Equatable {
  final String id;
  final String userId;
  final String deckId;
  final int cardsStudied;
  final int cardsCorrect;
  final int cardsIncorrect;
  final int studyDuration; // in seconds
  final DateTime sessionDate;
  final DateTime createdAt;

  const StudyProgress({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.cardsStudied,
    required this.cardsCorrect,
    required this.cardsIncorrect,
    required this.studyDuration,
    required this.sessionDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    deckId,
    cardsStudied,
    cardsCorrect,
    cardsIncorrect,
    studyDuration,
    sessionDate,
    createdAt,
  ];

  /// Get accuracy percentage (0-100)
  double get accuracy {
    if (cardsStudied == 0) return 0.0;
    return (cardsCorrect / cardsStudied) * 100;
  }

  /// Get average time per card in seconds
  double get averageTimePerCard {
    if (cardsStudied == 0) return 0.0;
    return studyDuration / cardsStudied;
  }

  /// Check if session was successful (>70% accuracy)
  bool get isSuccessful => accuracy >= 70.0;
}
