import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../../domain/entities/flashcard_card.dart';
import '../../domain/entities/study_session.dart';
import '../../domain/entities/flashcard_card_detail.dart';
import '../../domain/entities/flashcard_stats.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_remote_data_source.dart';
import '../models/study_session_model.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardRemoteDataSource remoteDataSource;

  FlashcardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FlashcardDeck>> createDeck({
    required String name,
    String? description,
    required String sourceType,
    int? sourceId,
    bool? isPublic,
  }) async {
    try {
      final deck = await remoteDataSource.createDeck(
        name: name,
        description: description,
        sourceType: sourceType,
        sourceId: sourceId,
        isPublic: isPublic,
      );
      return Right(deck);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FlashcardDeck>>> getUserDecks() async {
    try {
      final decks = await remoteDataSource.getUserDecks();
      return Right(decks);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> getDeckById(int deckId) async {
    try {
      final deck = await remoteDataSource.getDeckById(deckId);
      return Right(deck);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardCardDetail>> getCardDetail(int cardId) async {
    try {
      final detail = await remoteDataSource.getCardDetail(cardId);
      return Right(detail);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardDeck>> updateDeck({
    required int deckId,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final deck = await remoteDataSource.updateDeck(
        deckId: deckId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(deck);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck(int deckId) async {
    try {
      await remoteDataSource.deleteDeck(deckId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardCard>> addCardToDeck({
    required int deckId,
    required int kanjiId,
  }) async {
    try {
      final card = await remoteDataSource.addCardToDeck(
        deckId: deckId,
        kanjiId: kanjiId,
      );
      return Right(card);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeCardFromDeck(int cardId) async {
    try {
      await remoteDataSource.removeCardFromDeck(cardId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bulkAddCards({
    required int deckId,
    required List<int> kanjiIds,
  }) async {
    try {
      await remoteDataSource.bulkAddCards(deckId: deckId, kanjiIds: kanjiIds);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderCards({
    required int deckId,
    required List<int> cardIds,
  }) async {
    try {
      await remoteDataSource.reorderCards(deckId: deckId, cardIds: cardIds);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> startStudySession({
    required int deckId,
    int? maxCards,
    String? mode,
    bool? randomize,
    bool? includeNew,
    bool? includeDue,
    bool? includeHard,
    int? difficultyThreshold,
    bool? resumeExisting,
  }) async {
    try {
      final session = await remoteDataSource.startStudySession(
        deckId: deckId,
        maxCards: maxCards,
        mode: mode,
        randomize: randomize,
        includeNew: includeNew,
        includeDue: includeDue,
        includeHard: includeHard,
        difficultyThreshold: difficultyThreshold,
        resumeExisting: resumeExisting,
      );
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> reviewCard({
    required int sessionId,
    required int cardId,
    required int rating,
    required int timeSpent,
  }) async {
    try {
      final result = await remoteDataSource.reviewCard(
        sessionId: sessionId,
        cardId: cardId,
        rating: rating,
        timeSpent: timeSpent,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> completeSession(int sessionId) async {
    try {
      final session = await remoteDataSource.completeSession(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getStudyHistory({
    int? deckId,
  }) async {
    try {
      final historyPayload = await remoteDataSource.getStudyHistory(
        deckId: deckId,
      );

      final history = historyPayload
          .whereType<Map<String, dynamic>>()
          .map(_mapHistoryEntry)
          .toList();

      return Right(history);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> pauseSession(int sessionId) async {
    try {
      final session = await remoteDataSource.pauseSession(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> resumeSession(int sessionId) async {
    try {
      final session = await remoteDataSource.resumeSession(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudySession>> getSessionDetail(int sessionId) async {
    try {
      final session = await remoteDataSource.getSessionDetail(sessionId);
      return Right(session);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudySession>>> getActiveSessions({
    int? deckId,
  }) async {
    try {
      final sessions = await remoteDataSource.getActiveSessions(deckId: deckId);
      return Right(sessions);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  StudySessionModel _mapHistoryEntry(Map<String, dynamic> entry) {
    final stats = entry['stats'] as Map<String, dynamic>?;
    final meta = StudySessionMeta(
      totalCards: (stats?['cardsStudied'] as num?)?.toInt() ?? 0,
      reviewed: (stats?['cardsStudied'] as num?)?.toInt() ?? 0,
      remaining: 0,
      progress: 1,
    );

    final createAt = _parseDate(entry['startedAt']);
    final completedAt = _parseDate(entry['completedAt']);
    final resolvedCreateAt = createAt ?? DateTime.now().toUtc();
    final resolvedCompletedAt = completedAt ?? resolvedCreateAt;

    final sessionData = {
      'id': entry['id'] ?? -1,
      'deck_id': (entry['deck'] as Map<String, dynamic>?)?['id'] ?? -1,
      'user_id': entry['user_id'] ?? -1,
      'cards_studied': (stats?['cardsStudied'] as num?)?.toInt() ?? 0,
      'cards_correct': (stats?['cardsCorrect'] as num?)?.toInt() ?? 0,
      'cards_wrong': (stats?['cardsWrong'] as num?)?.toInt() ?? 0,
      'total_time': (stats?['totalTime'] as num?)?.toInt() ?? 0,
      'completed': true,
      'status': 'COMPLETED',
      'cards_total': meta.totalCards,
      'current_index': meta.totalCards,
      'card_order': const <int>[],
      'create_at': resolvedCreateAt.toIso8601String(),
      'update_at': resolvedCompletedAt.toIso8601String(),
      'completed_at': resolvedCompletedAt.toIso8601String(),
      'meta': {
        'totalCards': meta.totalCards,
        'reviewed': meta.reviewed,
        'remaining': meta.remaining,
        'progress': meta.progress,
      },
    };

    return StudySessionModel.fromJson(sessionData);
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  Future<Either<Failure, FlashcardStats>> getStats({int? deckId}) async {
    try {
      final stats = await remoteDataSource.getStats(deckId: deckId);
      return Right(stats);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
