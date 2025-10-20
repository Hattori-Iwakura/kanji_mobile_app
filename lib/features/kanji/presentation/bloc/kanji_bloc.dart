import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji_exception.dart';
import '../../domain/usecases/create_kanji_usecase.dart';
import '../../domain/usecases/delete_kanji_usecase.dart';
import '../../domain/usecases/get_kanji_by_character_usecase.dart';
import '../../domain/usecases/get_kanji_by_id_usecase.dart';
import '../../domain/usecases/get_kanji_list_usecase.dart';
import '../../domain/usecases/update_kanji_usecase.dart';
import 'kanji_event.dart';
import 'kanji_state.dart';

class KanjiBloc extends Bloc<KanjiEvent, KanjiState> {
  final GetKanjiListUseCase getKanjiListUseCase;
  final GetKanjiByIdUseCase getKanjiByIdUseCase;
  final GetKanjiByCharacterUseCase getKanjiByCharacterUseCase;
  final CreateKanjiUseCase createKanjiUseCase;
  final UpdateKanjiUseCase updateKanjiUseCase;
  final DeleteKanjiUseCase deleteKanjiUseCase;

  KanjiBloc({
    required this.getKanjiListUseCase,
    required this.getKanjiByIdUseCase,
    required this.getKanjiByCharacterUseCase,
    required this.createKanjiUseCase,
    required this.updateKanjiUseCase,
    required this.deleteKanjiUseCase,
  }) : super(KanjiInitial()) {
    on<LoadKanjiListEvent>(_onLoadKanjiList);
    on<LoadKanjiByIdEvent>(_onLoadKanjiById);
    on<LoadKanjiByCharacterEvent>(_onLoadKanjiByCharacter);
    on<CreateKanjiEvent>(_onCreateKanji);
    on<UpdateKanjiEvent>(_onUpdateKanji);
    on<DeleteKanjiEvent>(_onDeleteKanji);
    on<RefreshKanjiListEvent>(_onRefreshKanjiList);
  }

  Future<void> _onLoadKanjiList(
    LoadKanjiListEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    try {
      final kanjiList = await getKanjiListUseCase(
        page: event.page,
        limit: event.limit,
        jlptLevel: event.jlptLevel,
        grade: event.grade,
        search: event.search,
      );

      emit(
        KanjiListLoaded(
          kanjiList: kanjiList,
          currentPage: event.page,
          hasMore: kanjiList.length >= event.limit,
          appliedJlptFilter: event.jlptLevel,
          appliedGradeFilter: event.grade,
          appliedSearch: event.search,
        ),
      );
    } on KanjiException catch (e) {
      emit(KanjiError(e.message));
    } catch (e) {
      emit(KanjiError('Failed to load kanji list'));
    }
  }

  Future<void> _onLoadKanjiById(
    LoadKanjiByIdEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    try {
      final kanji = await getKanjiByIdUseCase(event.id);
      emit(KanjiDetailLoaded(kanji));
    } on KanjiException catch (e) {
      emit(KanjiError(e.message));
    } catch (e) {
      emit(KanjiError('Failed to load kanji'));
    }
  }

  Future<void> _onLoadKanjiByCharacter(
    LoadKanjiByCharacterEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    try {
      final kanji = await getKanjiByCharacterUseCase(event.character);
      emit(KanjiDetailLoaded(kanji));
    } on KanjiException catch (e) {
      emit(KanjiError(e.message));
    } catch (e) {
      emit(KanjiError('Failed to load kanji'));
    }
  }

  Future<void> _onCreateKanji(
    CreateKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    try {
      final kanji = await createKanjiUseCase(event.kanjiData);
      emit(KanjiCreated(kanji));
    } on KanjiException catch (e) {
      emit(KanjiError(e.message));
    } catch (e) {
      emit(KanjiError('Failed to create kanji'));
    }
  }

  Future<void> _onUpdateKanji(
    UpdateKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    try {
      final kanji = await updateKanjiUseCase(event.id, event.kanjiData);
      emit(KanjiUpdated(kanji));
    } on KanjiException catch (e) {
      emit(KanjiError(e.message));
    } catch (e) {
      emit(KanjiError('Failed to update kanji'));
    }
  }

  Future<void> _onDeleteKanji(
    DeleteKanjiEvent event,
    Emitter<KanjiState> emit,
  ) async {
    emit(KanjiLoading());

    try {
      await deleteKanjiUseCase(event.id);
      emit(KanjiDeleted());
    } on KanjiException catch (e) {
      emit(KanjiError(e.message));
    } catch (e) {
      emit(KanjiError('Failed to delete kanji'));
    }
  }

  Future<void> _onRefreshKanjiList(
    RefreshKanjiListEvent event,
    Emitter<KanjiState> emit,
  ) async {
    // Reload with default parameters
    add(LoadKanjiListEvent());
  }
}
