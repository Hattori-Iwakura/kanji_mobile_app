import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji_list.dart';
import '../../domain/repositories/kanji_list_repository.dart';
import '../datasources/kanji_list_remote_datasource.dart';

/// Implementation of KanjiListRepository
class KanjiListRepositoryImpl implements KanjiListRepository {
  final KanjiListRemoteDataSource remoteDataSource;

  KanjiListRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<KanjiList>>> getAllLists({
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await remoteDataSource.getAllLists(
        search: search,
        limit: limit,
        offset: offset,
      );
      final lists = response.data.map((model) => model.toEntity()).toList();
      return Right(lists);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KanjiList>> getListById(int id) async {
    try {
      final model = await remoteDataSource.getListById(id);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KanjiList>> createList({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    try {
      final model = await remoteDataSource.createList(
        name: name,
        description: description,
        kanjiIds: kanjiIds,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KanjiList>> updateList({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final model = await remoteDataSource.updateList(
        id: id,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteList(int id) async {
    try {
      await remoteDataSource.deleteList(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KanjiList>> addKanjiToList({
    required int listId,
    required int kanjiId,
  }) async {
    try {
      final model = await remoteDataSource.addKanjiToList(listId, kanjiId);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, KanjiList>> removeKanjiFromList({
    required int listId,
    required int kanjiId,
  }) async {
    try {
      final model = await remoteDataSource.removeKanjiFromList(listId, kanjiId);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<KanjiList>>> getListsByJlpt({
    required String jlptLevel,
  }) async {
    try {
      final response = await remoteDataSource.getListsByJlpt(jlptLevel);
      final lists = response.data.map((model) => model.toEntity()).toList();
      return Right(lists);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Map exception to appropriate Failure type
  Failure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString().replaceFirst('Exception: ', '');

    if (message.contains('Unauthorized')) {
      return UnauthorizedFailure(message);
    } else if (message.contains('not found')) {
      return NotFoundFailure(message);
    } else if (message.contains('Invalid')) {
      return BadRequestFailure(message);
    } else if (message.contains('Network') || message.contains('timeout')) {
      return NetworkFailure(message);
    }

    return ServerFailure(message);
  }
}
