import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';

/// Repository interface for KanjiList operations
abstract class KanjiListRepository {
  /// Get all kanji lists with optional filters
  Future<Either<Failure, List<KanjiList>>> getAllLists({
    String? search,
    int? limit,
    int? offset,
  });

  /// Get single kanji list by ID
  Future<Either<Failure, KanjiList>> getListById(int id);

  /// Create new kanji list
  Future<Either<Failure, KanjiList>> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
  });

  /// Update kanji list metadata
  Future<Either<Failure, KanjiList>> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  });

  /// Delete kanji list
  Future<Either<Failure, void>> deleteList(int id);

  /// Add kanji to list
  Future<Either<Failure, KanjiList>> addKanjiToList({
    required int listId,
    required int kanjiId,
  });

  /// Remove kanji from list
  Future<Either<Failure, KanjiList>> removeKanjiFromList({
    required int listId,
    required int kanjiId,
  });

  /// Get kanji lists filtered by JLPT level (N5, N4, N3, N2, N1)
  Future<Either<Failure, List<KanjiList>>> getListsByJlpt({
    required String jlptLevel,
  });
}
