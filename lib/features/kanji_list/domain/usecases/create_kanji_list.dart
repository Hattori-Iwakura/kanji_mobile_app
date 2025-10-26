import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for creating a new kanji list
class CreateKanjiList {
  final KanjiListRepository repository;

  CreateKanjiList(this.repository);

  Future<Either<Failure, KanjiList>> call({
    required String name,
    String? description,
    List<int>? kanjiIds,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      return Left(BadRequestFailure('List name cannot be empty'));
    }

    return await repository.createList(
      name: name,
      description: description,
      kanjiIds: kanjiIds,
    );
  }
}
