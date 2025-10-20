abstract class KanjiEvent {}

class LoadKanjiListEvent extends KanjiEvent {
  final int page;
  final int limit;
  final String? jlptLevel;
  final int? grade;
  final String? search;

  LoadKanjiListEvent({
    this.page = 1,
    this.limit = 50,
    this.jlptLevel,
    this.grade,
    this.search,
  });
}

class LoadKanjiByIdEvent extends KanjiEvent {
  final int id;

  LoadKanjiByIdEvent(this.id);
}

class LoadKanjiByCharacterEvent extends KanjiEvent {
  final String character;

  LoadKanjiByCharacterEvent(this.character);
}

class CreateKanjiEvent extends KanjiEvent {
  final Map<String, dynamic> kanjiData;

  CreateKanjiEvent(this.kanjiData);
}

class UpdateKanjiEvent extends KanjiEvent {
  final int id;
  final Map<String, dynamic> kanjiData;

  UpdateKanjiEvent(this.id, this.kanjiData);
}

class DeleteKanjiEvent extends KanjiEvent {
  final int id;

  DeleteKanjiEvent(this.id);
}

class RefreshKanjiListEvent extends KanjiEvent {}
