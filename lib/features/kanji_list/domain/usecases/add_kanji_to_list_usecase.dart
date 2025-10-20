import '../repositories/kanji_list_repository.dart';

class AddKanjiToListUseCase {
  final KanjiListRepository repository;

  AddKanjiToListUseCase(this.repository);

  Future<void> call({required int listId, required int kanjiId}) {
    return repository.addKanji(listId: listId, kanjiId: kanjiId);
  }
}
