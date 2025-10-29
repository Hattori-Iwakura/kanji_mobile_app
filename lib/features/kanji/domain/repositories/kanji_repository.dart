import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../entities/kanji_detail.dart';
import '../usecases/create_kanji.dart';
import '../usecases/update_kanji.dart';

abstract class KanjiRepository {
  /// Get all kanji with optional filters
  Future<Either<Failure, List<Kanji>>> getKanjiList({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  });

  /// Search kanji with advanced filters
  Future<Either<Failure, Map<String, dynamic>>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  });

  /// Get kanji by ID
  Future<Either<Failure, Kanji>> getKanjiById(int id);

  /// Get kanji by character
  Future<Either<Failure, Kanji>> getKanjiByCharacter(String character);

  /// Get detailed kanji info from external APIs
  Future<Either<Failure, KanjiDetail>> getKanjiDetail(String character);

  /// Search kanji by canvas drawing (AI recognition)
  Future<Either<Failure, List<Kanji>>> searchByCanvas(String imageBase64);

  /// Admin: Create new kanji
  Future<Either<Failure, Kanji>> createKanji(CreateKanjiParams params);

  /// Admin: Update existing kanji
  Future<Either<Failure, Kanji>> updateKanji(UpdateKanjiParams params);

  /// Admin: Delete kanji
  Future<Either<Failure, void>> deleteKanji(int id);
}
