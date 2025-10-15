import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_deck_by_id.dart';
import '../../domain/usecases/add_card_to_deck.dart';
import '../../domain/usecases/delete_card.dart';
import 'deck_detail_event.dart';
import 'deck_detail_state.dart';

class DeckDetailBloc extends Bloc<DeckDetailEvent, DeckDetailState> {
  final GetDeckById getDeckById;
  final AddCardToDeck addCardToDeck;
  final DeleteCard deleteCard;

  DeckDetailBloc({
    required this.getDeckById,
    required this.addCardToDeck,
    required this.deleteCard,
  }) : super(const DeckDetailInitial()) {
    on<LoadDeckDetailEvent>(_onLoadDeckDetail);
    on<AddCardToDeckEvent>(_onAddCard);
    on<DeleteCardEvent>(_onDeleteCard);
    on<RefreshDeckDetailEvent>(_onRefreshDeckDetail);
  }

  Future<void> _onLoadDeckDetail(
    LoadDeckDetailEvent event,
    Emitter<DeckDetailState> emit,
  ) async {
    emit(const DeckDetailLoading());

    final result = await getDeckById(event.deckId);

    result.fold(
      (failure) => emit(DeckDetailError(failure.message)),
      (deck) => emit(DeckDetailLoaded(deck)),
    );
  }

  Future<void> _onAddCard(
    AddCardToDeckEvent event,
    Emitter<DeckDetailState> emit,
  ) async {
    final result = await addCardToDeck(
      deckId: event.deckId,
      kanjiId: event.kanjiId,
    );

    await result.fold(
      (failure) async => emit(DeckDetailError(failure.message)),
      (_) async {
        // Reload deck after adding card
        add(RefreshDeckDetailEvent(event.deckId));
      },
    );
  }

  Future<void> _onDeleteCard(
    DeleteCardEvent event,
    Emitter<DeckDetailState> emit,
  ) async {
    // Keep current deck ID
    int? currentDeckId;
    if (state is DeckDetailLoaded) {
      currentDeckId = (state as DeckDetailLoaded).deck.id;
    }

    final result = await deleteCard(event.cardId);

    await result.fold(
      (failure) async => emit(DeckDetailError(failure.message)),
      (_) async {
        // Reload deck after deleting card
        if (currentDeckId != null) {
          add(RefreshDeckDetailEvent(currentDeckId));
        }
      },
    );
  }

  Future<void> _onRefreshDeckDetail(
    RefreshDeckDetailEvent event,
    Emitter<DeckDetailState> emit,
  ) async {
    final result = await getDeckById(event.deckId);

    result.fold(
      (failure) => emit(DeckDetailError(failure.message)),
      (deck) => emit(DeckDetailLoaded(deck)),
    );
  }
}
