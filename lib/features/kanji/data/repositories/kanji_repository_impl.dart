import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../datasources/kanji_remote_datasource.dart';

/// Implementation of KanjiRepository
class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiRemoteDataSource remoteDataSource;

  KanjiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Kanji>>> getAllKanji({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final kanjiModels = await remoteDataSource.getAllKanji(
        jlpt: jlpt,
        grade: grade,
        search: search,
        limit: limit,
        offset: offset,
      );
      return Right(kanjiModels.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Kanji>> getKanjiById(int id) async {
    try {
      final kanjiModel = await remoteDataSource.getKanjiById(id);
      return Right(kanjiModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Kanji>> getKanjiByCharacter(String character) async {
    try {
      final kanjiModel = await remoteDataSource.getKanjiByCharacter(character);
      return Right(kanjiModel.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      final kanjiModels = await remoteDataSource.searchKanji(
        query: query,
        jlptLevels: jlptLevels,
        grades: grades,
        minStrokes: minStrokes,
        maxStrokes: maxStrokes,
        page: page,
        limit: limit,
        sortBy: sortBy,
      );
      return Right(kanjiModels.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Failure _mapExceptionToFailure(Exception e) {
    final message = e.toString();

    if (message.contains('Unauthorized')) {
      return const UnauthorizedFailure();
    } else if (message.contains('Not found')) {
      return const NotFoundFailure();
    } else if (message.contains('Bad request')) {
      return const BadRequestFailure();
    } else if (message.contains('timeout') ||
        message.contains('Network error')) {
      return const NetworkFailure();
    } else if (message.contains('Server error')) {
      return const ServerFailure();
    }

    return UnknownFailure(message);
  }
}
