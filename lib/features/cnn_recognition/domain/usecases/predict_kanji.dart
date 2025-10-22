import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/prediction_result.dart';
import '../repositories/cnn_recognition_repository.dart';

/// Use case for predicting kanji from drawn image
class PredictKanji {
  final CnnRecognitionRepository repository;

  PredictKanji(this.repository);

  Future<Either<Failure, List<PredictionResult>>> call(
    List<int> imageBytes,
  ) async {
    return await repository.predictKanji(imageBytes);
  }
}
