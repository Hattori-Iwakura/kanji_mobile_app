import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction_result.dart';

/// Repository interface for CNN kanji recognition
abstract class CnnRecognitionRepository {
  /// Predict kanji from image bytes
  /// Returns top 5 predictions sorted by confidence
  Future<Either<Failure, List<PredictionResult>>> predictKanji(
    List<int> imageBytes,
  );

  /// Check if CNN server is available
  Future<Either<Failure, bool>> checkServerStatus();
}
