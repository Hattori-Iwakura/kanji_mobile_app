import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji_table.dart';
import '../../domain/repositories/kanji_table_repository.dart';
import '../datasources/kanji_table_remote_datasource.dart';

class KanjiTableRepositoryImpl implements KanjiTableRepository {
  final KanjiTableRemoteDataSource remoteDataSource;

  KanjiTableRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<KanjiTable>>> getTablesByJlpt(
    String jlptLevel,
  ) async {
    try {
      final tables = await remoteDataSource.getTablesByJlpt(jlptLevel);
      return Right(tables);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<KanjiTable>>> getAllTables({
    String? search,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final tables = await remoteDataSource.getAllTables(
        search: search,
        type: type,
        limit: limit,
        offset: offset,
      );
      return Right(tables);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KanjiTable>> getTableById(int id) async {
    try {
      final table = await remoteDataSource.getTableById(id);
      return Right(table);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KanjiTable>> createTable({
    required String name,
    String? description,
    int? categoryId,
    List<int>? kanjiIds,
  }) async {
    try {
      final table = await remoteDataSource.createTable(
        name: name,
        description: description,
        categoryId: categoryId,
        kanjiIds: kanjiIds,
      );
      return Right(table);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KanjiTable>> updateTable({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  }) async {
    try {
      final table = await remoteDataSource.updateTable(
        id: id,
        name: name,
        description: description,
        isPublic: isPublic,
        categoryId: categoryId,
      );
      return Right(table);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTable(int id) async {
    try {
      await remoteDataSource.deleteTable(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addKanjiToTable({
    required int tableId,
    required int kanjiId,
  }) async {
    try {
      await remoteDataSource.addKanjiToTable(
        tableId: tableId,
        kanjiId: kanjiId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KanjiTable>> removeKanjiFromTable({
    required int tableId,
    required int kanjiId,
  }) async {
    try {
      final table = await remoteDataSource.removeKanjiFromTable(
        tableId: tableId,
        kanjiId: kanjiId,
      );
      return Right(table);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PublishRequest>> requestPublish(int tableId) async {
    try {
      final request = await remoteDataSource.requestPublish(tableId);
      return Right(request);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PublishRequest>>> getPublishRequests({
    String? status,
  }) async {
    try {
      final requests = await remoteDataSource.getPublishRequests(
        status: status,
      );
      return Right(requests);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PublishRequest>> approvePublishRequest(
    int requestId,
  ) async {
    try {
      final request = await remoteDataSource.approvePublishRequest(requestId);
      return Right(request);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PublishRequest>> rejectPublishRequest({
    required int requestId,
    String? reason,
  }) async {
    try {
      final request = await remoteDataSource.rejectPublishRequest(
        requestId: requestId,
        reason: reason,
      );
      return Right(request);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? e.message ?? 'Server error',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
