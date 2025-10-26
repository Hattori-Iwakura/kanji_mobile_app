import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../entities/kanji_recognition_result.dart';

/// Repository interface for Kanji operations
abstract class KanjiRepository {
  /// Get all kanji with optional filters
  Future<Either<Failure, List<Kanji>>> getAllKanji({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  });

  /// Get kanji by ID
  Future<Either<Failure, Kanji>> getKanjiById(int id);

  /// Get kanji by character
  Future<Either<Failure, Kanji>> getKanjiByCharacter(String character);

  /// Search kanji with advanced filters
  Future<Either<Failure, List<Kanji>>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page,
    int limit,
    String? sortBy,
  });

  /// Recognize kanji from canvas drawing (base64 image)
  Future<Either<Failure, KanjiRecognitionResultEntity>> recognizeKanji(
    String base64Image,
  );
}
