import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/start_study_session.dart';
import '../../domain/usecases/review_card.dart';
import '../../domain/repositories/flashcard_repository.dart';
import 'study_session_event.dart';
import 'study_session_state.dart';

class StudySessionBloc extends Bloc<StudySessionEvent, StudySessionState> {
  final StartStudySession startStudySession;
  final ReviewCard reviewCard;
  final FlashcardRepository repository;

  StudySessionBloc({
    required this.startStudySession,
    required this.reviewCard,
    required this.repository,
  }) : super(const StudySessionInitial()) {
    on<StartStudySessionEvent>(_onStartStudySession);
    on<ReviewCardEvent>(_onReviewCard);
    on<NextCardEvent>(_onNextCard);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<ResetSessionEvent>(_onResetSession);
  }

  Future<void> _onStartStudySession(
    StartStudySessionEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    emit(const StudySessionLoading());

    final result = await startStudySession(
      deckId: event.deckId,
      maxCards: event.maxCards,
    );

    result.fold((failure) => emit(StudySessionError(failure.message)), (
      session,
    ) {
      if (session.cards == null || session.cards!.isEmpty) {
        emit(const StudySessionEmpty('No cards due for review'));
      } else {
        emit(
          StudySessionStarted(
            session: session,
            cards: session.cards!,
            currentCardIndex: 0,
            showAnswer: false,
          ),
        );
      }
    });
  }

  Future<void> _onReviewCard(
    ReviewCardEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    if (state is! StudySessionStarted) return;

    final currentState = state as StudySessionStarted;

    final result = await reviewCard(
      sessionId: event.sessionId,
      cardId: event.cardId,
      rating: event.rating,
      timeSpent: event.timeSpent,
    );

    result.fold((failure) => emit(StudySessionError(failure.message)), (
      reviewResult,
    ) {
      // Show review result briefly before moving to next card
      emit(
        StudySessionReviewSubmitted(
          reviewResult: reviewResult,
          currentCardIndex: currentState.currentCardIndex,
          totalCards: currentState.cards.length,
        ),
      );

      // Check if there are more cards
      if (currentState.hasMoreCards) {
        // Move to next card after a delay
        Future.delayed(const Duration(milliseconds: 500), () {
          add(const NextCardEvent());
        });
      } else {
        // Complete session
        add(CompleteSessionEvent(currentState.session.id));
      }
    });
  }

  Future<void> _onNextCard(
    NextCardEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    if (state is StudySessionStarted) {
      final currentState = state as StudySessionStarted;

      if (currentState.hasMoreCards) {
        emit(
          currentState.copyWith(
            currentCardIndex: currentState.currentCardIndex + 1,
            showAnswer: false,
          ),
        );
      }
    } else if (state is StudySessionReviewSubmitted) {
      final reviewState = state as StudySessionReviewSubmitted;

      // Need to get back to StudySessionStarted state
      // This should be handled by checking previous state
      // For now, we'll handle it in the UI by tracking the session
    }
  }

  Future<void> _onCompleteSession(
    CompleteSessionEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    emit(const StudySessionLoading());

    final result = await repository.completeSession(event.sessionId);

    result.fold(
      (failure) => emit(StudySessionError(failure.message)),
      (session) => emit(StudySessionCompleted(session)),
    );
  }

  void _onResetSession(
    ResetSessionEvent event,
    Emitter<StudySessionState> emit,
  ) {
    emit(const StudySessionInitial());
  }
}
