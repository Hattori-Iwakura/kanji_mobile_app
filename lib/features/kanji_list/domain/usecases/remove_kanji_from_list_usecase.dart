import '../repositories/kanji_list_repository.dart';

class RemoveKanjiFromListUseCase {
  final KanjiListRepository repository;

  RemoveKanjiFromListUseCase(this.repository);

  Future<void> call({required int listId, required int kanjiId}) {
    return repository.removeKanji(listId: listId, kanjiId: kanjiId);
  }
}
