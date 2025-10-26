import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_list.dart';
import '../repositories/kanji_list_repository.dart';

/// UseCase for updating kanji list metadata
class UpdateKanjiList {
  final KanjiListRepository repository;

  UpdateKanjiList(this.repository);

  Future<Either<Failure, KanjiList>> call({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    // Validate if at least one field is provided
    if (name == null && description == null && isPublic == null) {
      return Left(BadRequestFailure('At least one field must be provided'));
    }

    // Validate name if provided
    if (name != null && name.trim().isEmpty) {
      return Left(BadRequestFailure('List name cannot be empty'));
    }

    return await repository.updateList(
      id: id,
      name: name,
      description: description,
      isPublic: isPublic,
    );
  }
}
