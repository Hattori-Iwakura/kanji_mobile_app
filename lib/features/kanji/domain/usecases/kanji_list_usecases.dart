import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_repository.dart';

// Create List UseCase
class CreateKanjiListUseCase {
  final KanjiRepository repository;

  CreateKanjiListUseCase(this.repository);

  Future<Either<Failure, KanjiList>> call(CreateKanjiListParams params) async {
    return await repository.createList(
      name: params.name,
      description: params.description,
      isPublic: params.isPublic,
    );
  }
}

class CreateKanjiListParams extends Equatable {
  final String name;
  final String? description;
  final bool? isPublic;

  const CreateKanjiListParams({
    required this.name,
    this.description,
    this.isPublic = false,
  });

  @override
  List<Object?> get props => [name, description, isPublic];
}

// Get User Lists UseCase
class GetUserListsUseCase {
  final KanjiRepository repository;

  GetUserListsUseCase(this.repository);

  Future<Either<Failure, List<KanjiList>>> call() async {
    return await repository.getUserLists();
  }
}

// Get List Detail UseCase
class GetListDetailUseCase {
  final KanjiRepository repository;

  GetListDetailUseCase(this.repository);

  Future<Either<Failure, KanjiList>> call(int listId) async {
    return await repository.getListDetail(listId);
  }
}

// Add to List UseCase
class AddKanjiToListUseCase {
  final KanjiRepository repository;

  AddKanjiToListUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    AddKanjiToListParams params,
  ) async {
    return await repository.addKanjiToList(
      listId: params.listId,
      kanjiCharacters: params.kanjiCharacters,
      notes: params.notes,
    );
  }
}

class AddKanjiToListParams extends Equatable {
  final int listId;
  final List<String> kanjiCharacters;
  final String? notes;

  const AddKanjiToListParams({
    required this.listId,
    required this.kanjiCharacters,
    this.notes,
  });

  @override
  List<Object?> get props => [listId, kanjiCharacters, notes];
}

// Remove from List UseCase
class RemoveKanjiFromListUseCase {
  final KanjiRepository repository;

  RemoveKanjiFromListUseCase(this.repository);

  Future<Either<Failure, void>> call(RemoveKanjiFromListParams params) async {
    return await repository.removeKanjiFromList(
      listId: params.listId,
      kanjiId: params.kanjiId,
    );
  }
}

class RemoveKanjiFromListParams extends Equatable {
  final int listId;
  final int kanjiId;

  const RemoveKanjiFromListParams({
    required this.listId,
    required this.kanjiId,
  });

  @override
  List<Object?> get props => [listId, kanjiId];
}

// Delete List UseCase
class DeleteKanjiListUseCase {
  final KanjiRepository repository;

  DeleteKanjiListUseCase(this.repository);

  Future<Either<Failure, void>> call(int listId) async {
    return await repository.deleteList(listId);
  }
}

// Reorder List UseCase
class ReorderKanjiListUseCase {
  final KanjiRepository repository;

  ReorderKanjiListUseCase(this.repository);

  Future<Either<Failure, void>> call(ReorderKanjiListParams params) async {
    return await repository.reorderList(
      listId: params.listId,
      kanjiIds: params.kanjiIds,
    );
  }
}

class ReorderKanjiListParams extends Equatable {
  final int listId;
  final List<int> kanjiIds;

  const ReorderKanjiListParams({required this.listId, required this.kanjiIds});

  @override
  List<Object?> get props => [listId, kanjiIds];
}
