import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../entities/kanji_detail.dart';
import '../entities/kanji_example.dart';
import '../entities/kanji_list.dart';
import '../entities/kanji_progress.dart';
import '../entities/kanji_search_result.dart';
import '../entities/progress_summary.dart';
import '../usecases/create_kanji.dart';
import '../usecases/update_kanji.dart';

abstract class KanjiRepository {
  // ==================== Basic CRUD ====================
  Future<Either<Failure, List<Kanji>>> getAllKanji();
  Future<Either<Failure, Kanji>> getKanjiById(int id);
  Future<Either<Failure, Kanji>> getKanjiByCharacter(String character);
  Future<Either<Failure, List<Kanji>>> getKanjiByJlpt(int level);
  Future<Either<Failure, List<Kanji>>> getKanjiByGrade(int grade);

  // CRUD methods for Admin
  Future<Either<Failure, Kanji>> createKanji(CreateKanjiParams params);
  Future<Either<Failure, Kanji>> updateKanji(UpdateKanjiParams params);
  Future<Either<Failure, Kanji>> deleteKanji(int id);

  // ==================== Search & Filter ====================
  Future<Either<Failure, KanjiSearchResult>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    String? radical,
    int? page,
    int? limit,
    String? sortBy,
  });

  // ==================== Kanji Detail & Examples ====================
  Future<Either<Failure, KanjiDetail>> getKanjiDetail(String character);
  Future<Either<Failure, List<KanjiExample>>> getKanjiExamples(
    String character, {
    int? limit,
  });

  // ==================== Kanji Lists ====================
  Future<Either<Failure, KanjiList>> createList({
    required String name,
    String? description,
    bool? isPublic,
  });

  Future<Either<Failure, List<KanjiList>>> getUserLists();

  Future<Either<Failure, KanjiList>> getListDetail(int listId);

  Future<Either<Failure, Map<String, dynamic>>> addKanjiToList({
    required int listId,
    required List<String> kanjiCharacters,
    String? notes,
  });

  Future<Either<Failure, void>> removeKanjiFromList({
    required int listId,
    required int kanjiId,
  });

  Future<Either<Failure, void>> deleteList(int listId);

  Future<Either<Failure, void>> reorderList({
    required int listId,
    required List<int> kanjiIds,
  });

  // ==================== Progress Tracking ====================
  Future<Either<Failure, ProgressSummary>> getProgressSummary();

  Future<Either<Failure, KanjiProgress?>> getKanjiProgress(String character);

  Future<Either<Failure, KanjiProgress>> updateProgress({
    required String character,
    required ProgressStatus status,
  });

  Future<Either<Failure, KanjiProgress>> recordReview({
    required String character,
    required bool correct,
  });
}
