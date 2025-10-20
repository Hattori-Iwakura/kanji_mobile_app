import '../repositories/kanji_list_repository.dart';

class DeleteListUseCase {
  final KanjiListRepository repository;

  DeleteListUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteList(id);
  }
}
