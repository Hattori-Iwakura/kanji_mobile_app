import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/domain/entities/kanji_entity.dart';
import 'package:kanji_flutter/domain/repositories/kanji_repository.dart';

// State
class KanjiState {
  final List<Kanji> kanjis;
  final bool loading;
  KanjiState({this.kanjis = const [], this.loading = false});
}

// Event
abstract class KanjiEvent {}

class LoadKanjis extends KanjiEvent {}

class AddKanjiEvent extends KanjiEvent {
  final Kanji kanji;
  AddKanjiEvent(this.kanji);
}

class UpdateKanjiEvent extends KanjiEvent {
  final int id;
  final Kanji kanji;
  UpdateKanjiEvent(this.id, this.kanji);
}

class DeleteKanjiEvent extends KanjiEvent {
  final int id;
  DeleteKanjiEvent(this.id);
}

class SearchKanjiEvent extends KanjiEvent {
  final String query;
  SearchKanjiEvent(this.query);
}

// Bloc
class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final KanjiRepository repo;
  List<Kanji> _allKanjis = [];

  KanjiBloc(this.repo) : super(KanjiState()) {
    on<LoadKanjis>((event, emit) async {
      emit(KanjiState(loading: true));
      _allKanjis = await repo.getAll();
      emit(KanjiState(kanjis: _allKanjis));
    });

    on<AddKanjiEvent>((event, emit) async {
      final newKanji = await repo.create(event.kanji.toJson());
      _allKanjis.add(newKanji);
      emit(KanjiState(kanjis: _allKanjis));
    });

    on<UpdateKanjiEvent>((event, emit) async {
      final updated = await repo.update(event.id, event.kanji.toJson());
      _allKanjis = _allKanjis
          .map((k) => k.id == event.id ? updated : k)
          .toList();
      emit(KanjiState(kanjis: _allKanjis));
    });

    on<DeleteKanjiEvent>((event, emit) async {
      await repo.delete(event.id);
      _allKanjis.removeWhere((k) => k.id == event.id);
      emit(KanjiState(kanjis: _allKanjis));
    });

    on<SearchKanjiEvent>((event, emit) {
      final filtered = _allKanjis
          .where(
            (k) =>
                k.character.contains(event.query) ||
                k.meanings.contains(event.query),
          )
          .toList();
      emit(KanjiState(kanjis: filtered));
    });
  }
}
