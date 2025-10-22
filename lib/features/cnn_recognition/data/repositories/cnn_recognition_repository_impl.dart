import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/repositories/cnn_recognition_repository.dart';
import '../datasources/cnn_recognition_remote_datasource.dart';

/// Implementation of CnnRecognitionRepository
class CnnRecognitionRepositoryImpl implements CnnRecognitionRepository {
  final CnnRecognitionRemoteDataSource remoteDataSource;

  CnnRecognitionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PredictionResult>>> predictKanji(
    List<int> imageBytes,
  ) async {
    try {
      final predictionModels = await remoteDataSource.predictKanji(imageBytes);
      final predictions = predictionModels
          .map((model) => model.toEntity())
          .toList();
      return Right(predictions);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkServerStatus() async {
    try {
      final isOnline = await remoteDataSource.checkServerStatus();
      return Right(isOnline);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Exception e) {
    final message = e.toString();

    if (message.contains('timeout') || message.contains('Cannot connect')) {
      return NetworkFailure(message);
    } else if (message.contains('Invalid image')) {
      return const BadRequestFailure();
    } else if (message.contains('Server error')) {
      return const ServerFailure();
    }

    return UnknownFailure(message);
  }
}
