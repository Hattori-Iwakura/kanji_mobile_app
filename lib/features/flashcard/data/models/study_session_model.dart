import '../../domain/entities/study_session.dart';
import 'flashcard_card_model.dart';

class StudySessionModel extends StudySession {
  const StudySessionModel({
    required super.id,
    required super.deckId,
    required super.userId,
    required super.cardsStudied,
    required super.cardsCorrect,
    required super.cardsWrong,
    required super.totalTime,
    required super.completed,
    required super.status,
    required super.cardsTotal,
    required super.currentIndex,
    required super.cardOrder,
    required super.createAt,
    required super.updateAt,
    required super.meta,
    super.settings,
    super.pausedAt,
    super.completedAt,
    super.cards,
  });

  factory StudySessionModel.fromEnvelope(Map<String, dynamic> payload) {
    final sessionJson = Map<String, dynamic>.from(
      payload['session'] as Map<String, dynamic>,
    );
    final cardsJson = (payload['cards'] as List?) ?? const [];
    final metaJson = payload['meta'] as Map<String, dynamic>?;

    sessionJson['cards'] = cardsJson;
    sessionJson['meta'] = metaJson;

    return StudySessionModel.fromJson(sessionJson);
  }

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    final meta = _parseMeta(json['meta']);
    final settings = _parseSettings(json['settings']);

    return StudySessionModel(
      id: json['id'] as int,
      deckId: json['deck_id'] as int,
      userId: json['user_id'] as int,
      cardsStudied: json['cards_studied'] as int? ?? 0,
      cardsCorrect: json['cards_correct'] as int? ?? 0,
      cardsWrong: json['cards_wrong'] as int? ?? 0,
      totalTime: json['total_time'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      status:
          json['status'] as String? ??
          (json['completed'] == true ? 'COMPLETED' : 'ACTIVE'),
      cardsTotal: json['cards_total'] as int? ?? meta.totalCards,
      currentIndex: json['current_index'] as int? ?? meta.reviewed,
      cardOrder:
          (json['card_order'] as List?)
              ?.whereType<num>()
              .map((value) => value.toInt())
              .toList() ??
          const <int>[],
      createAt: DateTime.parse(json['create_at'] as String),
      updateAt: DateTime.parse(json['update_at'] as String),
      pausedAt: json['paused_at'] != null
          ? DateTime.tryParse(json['paused_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      meta: meta,
      settings: settings,
      cards: json['cards'] != null
          ? (json['cards'] as List)
                .whereType<Map<String, dynamic>>()
                .map(FlashcardCardModel.fromJson)
                .toList()
          : null,
    );
  }

  factory StudySessionModel.empty({
    required int deckId,
    List<dynamic>? cards,
    StudySessionMeta? meta,
  }) {
    final now = DateTime.now().toUtc();
    final parsedCards = cards == null
        ? <FlashcardCardModel>[]
        : cards
              .whereType<Map<String, dynamic>>()
              .map(FlashcardCardModel.fromJson)
              .toList();

    return StudySessionModel(
      id: -1,
      deckId: deckId,
      userId: -1,
      cardsStudied: 0,
      cardsCorrect: 0,
      cardsWrong: 0,
      totalTime: 0,
      completed: false,
      status: 'ACTIVE',
      cardsTotal: parsedCards.length,
      currentIndex: 0,
      cardOrder: parsedCards.map((card) => card.id).toList(),
      createAt: now,
      updateAt: now,
      meta: meta ?? const StudySessionMeta.empty(),
      cards: parsedCards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'user_id': userId,
      'cards_studied': cardsStudied,
      'cards_correct': cardsCorrect,
      'cards_wrong': cardsWrong,
      'total_time': totalTime,
      'completed': completed,
      'status': status,
      'cards_total': cardsTotal,
      'current_index': currentIndex,
      'card_order': cardOrder,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
      'paused_at': pausedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'settings': settings != null
          ? {
              'max_cards': settings!.maxCards,
              'mode': settings!.mode,
              'randomize': settings!.randomize,
              'include_new': settings!.includeNew,
              'include_due': settings!.includeDue,
              'include_hard': settings!.includeHard,
              'difficulty_threshold': settings!.difficultyThreshold,
            }
          : null,
      'meta': {
        'totalCards': meta.totalCards,
        'reviewed': meta.reviewed,
        'remaining': meta.remaining,
        'progress': meta.progress,
      },
      'cards': cards
          ?.map((card) => (card as FlashcardCardModel).toJson())
          .toList(),
    };
  }

  static StudySessionMeta _parseMeta(dynamic rawMeta) {
    if (rawMeta is Map<String, dynamic>) {
      return StudySessionMeta(
        totalCards: (rawMeta['totalCards'] as num?)?.toInt() ?? 0,
        reviewed: (rawMeta['reviewed'] as num?)?.toInt() ?? 0,
        remaining: (rawMeta['remaining'] as num?)?.toInt() ?? 0,
        progress: (rawMeta['progress'] as num?)?.toDouble() ?? 0,
      );
    }
    return const StudySessionMeta.empty();
  }

  static StudySessionSettings? _parseSettings(dynamic rawSettings) {
    if (rawSettings is! Map<String, dynamic>) return null;
    return StudySessionSettings(
      maxCards: (rawSettings['max_cards'] as num?)?.toInt(),
      mode: rawSettings['mode'] as String? ?? 'mixed',
      randomize: rawSettings['randomize'] as bool? ?? false,
      includeNew: rawSettings['include_new'] as bool? ?? true,
      includeDue: rawSettings['include_due'] as bool? ?? true,
      includeHard: rawSettings['include_hard'] as bool? ?? false,
      difficultyThreshold:
          (rawSettings['difficulty_threshold'] as num?)?.toInt() ?? 2,
    );
  }
}
