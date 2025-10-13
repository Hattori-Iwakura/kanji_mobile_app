import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/kanji_list_repository.dart';

class DeleteKanjiList implements UseCase<void, DeleteListParams> {
  final KanjiListRepository repository;

  DeleteKanjiList(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteListParams params) async {
    return await repository.deleteList(params.listId);
  }
}

class DeleteListParams {
  final int listId;

  DeleteListParams({required this.listId});
}
