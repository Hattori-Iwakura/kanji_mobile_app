import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_card_detail.dart';
import 'card_detail_state.dart';

class CardDetailCubit extends Cubit<CardDetailState> {
  final GetCardDetail getCardDetail;

  CardDetailCubit({required this.getCardDetail})
    : super(const CardDetailInitial());

  Future<void> load(int cardId) async {
    emit(const CardDetailLoading());
    final result = await getCardDetail(cardId);

    result.fold(
      (failure) => emit(CardDetailError(failure.message)),
      (detail) => emit(CardDetailLoaded(detail)),
    );
  }
}
