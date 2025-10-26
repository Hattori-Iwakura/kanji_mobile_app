import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/progress_overview.dart';
import '../../domain/entities/flashcard_progress.dart';
import '../../domain/entities/quiz_progress.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/chart_data.dart';
import '../../domain/entities/study_time.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource remoteDataSource;

  ProgressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProgressOverview>> getProgressOverview() async {
    try {
      final result = await remoteDataSource.getProgressOverview();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FlashcardProgress>> getFlashcardProgress({
    String? period,
  }) async {
    try {
      final result = await remoteDataSource.getFlashcardProgress(
        period: period,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuizProgress>> getQuizProgress({
    String? period,
  }) async {
    try {
      final result = await remoteDataSource.getQuizProgress(period: period);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Streak>> getStreak() async {
    try {
      final result = await remoteDataSource.getStreak();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Leaderboard>> getLeaderboard({
    String? period,
    String? type,
    int? limit,
  }) async {
    try {
      final result = await remoteDataSource.getLeaderboard(
        period: period,
        type: type,
        limit: limit,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AchievementsOverview>> getAchievements() async {
    try {
      final result = await remoteDataSource.getAchievements();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChartData>> getChartData() async {
    try {
      final result = await remoteDataSource.getChartData();
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudyTime>> getStudyTime({String? period}) async {
    try {
      final result = await remoteDataSource.getStudyTime(period: period);
      return Right(result);
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(message: 'Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AuthenticationFailure(
            message: 'Session expired. Please login again.',
          );
        } else if (statusCode == 404) {
          return NotFoundFailure(message: 'Progress data not found.');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure(message: 'Server error. Please try again.');
        }
        return ServerFailure(
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      case DioExceptionType.cancel:
        return NetworkFailure(message: 'Request cancelled.');
      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'No internet connection. Please check your connection.',
        );
      default:
        return UnknownFailure(message: error.message ?? 'Unknown error');
    }
  }
}
