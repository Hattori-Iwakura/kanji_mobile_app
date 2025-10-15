import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_recognition_result.dart';

abstract class KanjiRecognitionRepository {
  Future<Either<Failure, KanjiRecognitionResult>> recognizeKanji(
    String base64Image,
  );
}
