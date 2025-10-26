import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_recognition_result.dart';
import '../repositories/kanji_repository.dart';

/// UseCase for recognizing kanji from canvas drawing
class RecognizeKanji {
  final KanjiRepository repository;

  RecognizeKanji(this.repository);

  Future<Either<Failure, KanjiRecognitionResultEntity>> call(
    String base64Image,
  ) async {
    return await repository.recognizeKanji(base64Image);
  }
}
