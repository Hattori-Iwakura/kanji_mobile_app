import '../repositories/kanji_repository.dart';

class DeleteKanjiUseCase {
  final KanjiRepository repository;

  DeleteKanjiUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.deleteKanji(id);
  }
}
