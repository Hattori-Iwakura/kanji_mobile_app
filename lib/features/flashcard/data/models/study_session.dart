import 'package:equatable/equatable.dart';
import 'flashcard_card.dart';

class StudySession extends Equatable {
  final int id;
  final int deckId;
  final int userId;
  final int cardsStudied;
  final int cardsCorrect;
  final int cardsWrong;
  final int totalTime;
  final bool completed;
  final String status;
  final int cardsTotal;
  final int currentIndex;
  final List<int> cardOrder;
  final StudySessionSettings? settings;
  final DateTime? pausedAt;
  final DateTime? completedAt;
  final DateTime createAt;
  final DateTime updateAt;
  final StudySessionMeta meta;
  final List<FlashcardCard>? cards;

  const StudySession({
    required this.id,
    required this.deckId,
    required this.userId,
    required this.cardsStudied,
    required this.cardsCorrect,
    required this.cardsWrong,
    required this.totalTime,
    required this.completed,
    required this.status,
    required this.cardsTotal,
    required this.currentIndex,
    required this.cardOrder,
    required this.createAt,
    required this.updateAt,
    required this.meta,
    this.settings,
    this.pausedAt,
    this.completedAt,
    this.cards,
  });

  bool get isPaused => status == 'PAUSED';
  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED' || completed;

  StudySession copyWith({
    int? id,
    int? deckId,
    int? userId,
    int? cardsStudied,
    int? cardsCorrect,
    int? cardsWrong,
    int? totalTime,
    bool? completed,
    String? status,
    int? cardsTotal,
    int? currentIndex,
    List<int>? cardOrder,
    StudySessionSettings? settings,
    DateTime? pausedAt,
    DateTime? completedAt,
    DateTime? createAt,
    DateTime? updateAt,
    StudySessionMeta? meta,
    List<FlashcardCard>? cards,
  }) {
    return StudySession(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      userId: userId ?? this.userId,
      cardsStudied: cardsStudied ?? this.cardsStudied,
      cardsCorrect: cardsCorrect ?? this.cardsCorrect,
      cardsWrong: cardsWrong ?? this.cardsWrong,
      totalTime: totalTime ?? this.totalTime,
      completed: completed ?? this.completed,
      status: status ?? this.status,
      cardsTotal: cardsTotal ?? this.cardsTotal,
      currentIndex: currentIndex ?? this.currentIndex,
      cardOrder: cardOrder ?? this.cardOrder,
      settings: settings ?? this.settings,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      meta: meta ?? this.meta,
      cards: cards ?? this.cards,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deckId,
    userId,
    cardsStudied,
    cardsCorrect,
    cardsWrong,
    totalTime,
    completed,
    status,
    cardsTotal,
    currentIndex,
    cardOrder,
    settings,
    pausedAt,
    completedAt,
    createAt,
    updateAt,
    meta,
    cards,
  ];
}

class StudySessionMeta extends Equatable {
  final int totalCards;
  final int reviewed;
  final int remaining;
  final double progress;

  const StudySessionMeta({
    required this.totalCards,
    required this.reviewed,
    required this.remaining,
    required this.progress,
  });

  const StudySessionMeta.empty()
    : totalCards = 0,
      reviewed = 0,
      remaining = 0,
      progress = 0;

  StudySessionMeta copyWith({
    int? totalCards,
    int? reviewed,
    int? remaining,
    double? progress,
  }) {
    return StudySessionMeta(
      totalCards: totalCards ?? this.totalCards,
      reviewed: reviewed ?? this.reviewed,
      remaining: remaining ?? this.remaining,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object> get props => [totalCards, reviewed, remaining, progress];
}

class StudySessionSettings extends Equatable {
  final int? maxCards;
  final String mode;
  final bool randomize;
  final bool includeNew;
  final bool includeDue;
  final bool includeHard;
  final int difficultyThreshold;

  const StudySessionSettings({
    this.maxCards,
    this.mode = 'mixed',
    this.randomize = false,
    this.includeNew = true,
    this.includeDue = true,
    this.includeHard = false,
    this.difficultyThreshold = 2,
  });

  @override
  List<Object?> get props => [
    maxCards,
    mode,
    randomize,
    includeNew,
    includeDue,
    includeHard,
    difficultyThreshold,
  ];
}
