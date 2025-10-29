import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_table.dart';
import '../repositories/kanji_table_repository.dart';

class GetTablesByJlptUseCase {
  final KanjiTableRepository repository;

  GetTablesByJlptUseCase(this.repository);

  Future<Either<Failure, List<KanjiTable>>> call(String jlptLevel) {
    return repository.getTablesByJlpt(jlptLevel);
  }
}

class GetAllTablesUseCase {
  final KanjiTableRepository repository;

  GetAllTablesUseCase(this.repository);

  Future<Either<Failure, List<KanjiTable>>> call({
    String? search,
    String? type,
    int? limit,
    int? offset,
  }) {
    return repository.getAllTables(
      search: search,
      type: type,
      limit: limit,
      offset: offset,
    );
  }
}

class GetTableByIdUseCase {
  final KanjiTableRepository repository;

  GetTableByIdUseCase(this.repository);

  Future<Either<Failure, KanjiTable>> call(int id) {
    return repository.getTableById(id);
  }
}

class CreateTableUseCase {
  final KanjiTableRepository repository;

  CreateTableUseCase(this.repository);

  Future<Either<Failure, KanjiTable>> call({
    required String name,
    String? description,
    int? categoryId,
    List<int>? kanjiIds,
  }) {
    return repository.createTable(
      name: name,
      description: description,
      categoryId: categoryId,
      kanjiIds: kanjiIds,
    );
  }
}

class UpdateTableUseCase {
  final KanjiTableRepository repository;

  UpdateTableUseCase(this.repository);

  Future<Either<Failure, KanjiTable>> call({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  }) {
    return repository.updateTable(
      id: id,
      name: name,
      description: description,
      isPublic: isPublic,
      categoryId: categoryId,
    );
  }
}

class DeleteTableUseCase {
  final KanjiTableRepository repository;

  DeleteTableUseCase(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteTable(id);
  }
}

class AddKanjiToTableUseCase {
  final KanjiTableRepository repository;

  AddKanjiToTableUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required int tableId,
    required int kanjiId,
  }) {
    return repository.addKanjiToTable(tableId: tableId, kanjiId: kanjiId);
  }
}

class RemoveKanjiFromTableUseCase {
  final KanjiTableRepository repository;

  RemoveKanjiFromTableUseCase(this.repository);

  Future<Either<Failure, KanjiTable>> call({
    required int tableId,
    required int kanjiId,
  }) {
    return repository.removeKanjiFromTable(tableId: tableId, kanjiId: kanjiId);
  }
}

class RequestPublishUseCase {
  final KanjiTableRepository repository;

  RequestPublishUseCase(this.repository);

  Future<Either<Failure, PublishRequest>> call(int tableId) {
    return repository.requestPublish(tableId);
  }
}
