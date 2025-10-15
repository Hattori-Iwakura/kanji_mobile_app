import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_recognition_result.dart';
import '../repositories/kanji_recognition_repository.dart';

class RecognizeKanji {
  final KanjiRecognitionRepository repository;

  RecognizeKanji(this.repository);

  Future<Either<Failure, KanjiRecognitionResult>> call(
    String base64Image,
  ) async {
    return await repository.recognizeKanji(base64Image);
  }
}
