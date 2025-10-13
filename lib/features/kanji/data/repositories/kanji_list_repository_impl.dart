import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji_list.dart';
import '../../domain/repositories/kanji_list_repository.dart';
import '../datasources/kanji_list_local_data_source.dart';

class KanjiListRepositoryImpl implements KanjiListRepository {
  final KanjiListLocalDataSource localDataSource;

  KanjiListRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<KanjiList>>> getAllLists() async {
    try {
      final lists = await localDataSource.getAllLists();
      return Right(lists);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, KanjiList>> getListById(int id) async {
    try {
      final list = await localDataSource.getListById(id);
      return Right(list);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, KanjiList>> createList(KanjiList kanjiList) async {
    try {
      final model = _toModel(kanjiList);
      final created = await localDataSource.createList(model);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateList(KanjiList kanjiList) async {
    try {
      final model = _toModel(kanjiList);
      await localDataSource.updateList(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteList(int id) async {
    try {
      await localDataSource.deleteList(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<int>>> getKanjiIdsInList(int listId) async {
    try {
      final ids = await localDataSource.getKanjiIdsInList(listId);
      return Right(ids);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addKanjiToList(
    int listId,
    List<int> kanjiIds,
  ) async {
    try {
      await localDataSource.addKanjiToList(listId, kanjiIds);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeKanjiFromList(
    int listId,
    int kanjiId,
  ) async {
    try {
      await localDataSource.removeKanjiFromList(listId, kanjiId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  // Helper method to convert entity to model
  dynamic _toModel(KanjiList entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'description': entity.description,
      'filter_type': _filterTypeToString(entity.filterType),
      'filter_value': entity.filterValue,
      'frequency_min': entity.frequencyMin,
      'frequency_max': entity.frequencyMax,
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
      'kanji_count': entity.kanjiCount,
    };
  }

  String _filterTypeToString(ListFilterType type) {
    switch (type) {
      case ListFilterType.jlptLevel:
        return 'jlpt_level';
      case ListFilterType.frequency:
        return 'frequency';
      case ListFilterType.grade:
        return 'grade';
      case ListFilterType.custom:
        return 'custom';
    }
  }
}
