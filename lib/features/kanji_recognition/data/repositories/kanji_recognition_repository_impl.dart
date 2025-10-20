import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji_recognition_result.dart';
import '../../domain/repositories/kanji_recognition_repository.dart';
import '../datasources/kanji_recognition_remote_datasource.dart';

class KanjiRecognitionRepositoryImpl implements KanjiRecognitionRepository {
  final KanjiRecognitionRemoteDataSource remoteDataSource;

  KanjiRecognitionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, KanjiRecognitionResult>> recognizeKanji(
    String base64Image,
  ) async {
    try {
      final result = await remoteDataSource.recognizeKanji(base64Image);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
