import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/flashcard_card.dart';
import '../../domain/usecases/start_study_session.dart';
import '../../domain/usecases/review_card.dart';
import '../../domain/usecases/pause_study_session.dart';
import '../../domain/usecases/resume_study_session.dart';
import '../../domain/usecases/get_active_sessions.dart';
import '../../domain/usecases/get_session_detail.dart';
import '../../domain/repositories/flashcard_repository.dart';
import 'study_session_event.dart';
import 'study_session_state.dart';

class StudySessionBloc extends Bloc<StudySessionEvent, StudySessionState> {
  final StartStudySession startStudySession;
  final ReviewCard reviewCard;
  final FlashcardRepository repository;
  final PauseStudySession pauseSession;
  final ResumeStudySession resumeSession;
  final GetActiveSessions getActiveSessions;
  final GetSessionDetail getSessionDetail;

  StudySessionBloc({
    required this.startStudySession,
    required this.reviewCard,
    required this.repository,
    required this.pauseSession,
    required this.resumeSession,
    required this.getActiveSessions,
    required this.getSessionDetail,
  }) : super(const StudySessionInitial()) {
    on<InitializeStudySessionEvent>(_onInitializeSession);
    on<StartStudySessionEvent>(_onStartStudySession);
    on<ReviewCardEvent>(_onReviewCard);
    on<CompleteSessionEvent>(_onCompleteSession);
    on<ResetSessionEvent>(_onResetSession);
    on<ResumeExistingSessionEvent>(_onResumeSession);
    on<PauseCurrentSessionEvent>(_onPauseSession);
  }

  Future<void> _onInitializeSession(
    InitializeStudySessionEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    emit(const StudySessionLoading());

    final activeResult = await getActiveSessions(deckId: event.deckId);

    activeResult.fold(
      (failure) => emit(StudySessionError(failure.message)),
      (sessions) => emit(
        StudySessionSetup(deckId: event.deckId, activeSessions: sessions),
      ),
    );
  }

  Future<void> _onStartStudySession(
    StartStudySessionEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    emit(const StudySessionLoading());

    final result = await startStudySession(
      deckId: event.deckId,
      maxCards: event.maxCards,
      mode: event.mode,
      randomize: event.randomize,
      includeNew: event.includeNew,
      includeDue: event.includeDue,
      includeHard: event.includeHard,
      difficultyThreshold: event.difficultyThreshold,
      resumeExisting: event.resumeExisting,
    );

    result.fold(
      (failure) {
        emit(StudySessionError(failure.message));
        add(InitializeStudySessionEvent(event.deckId));
      },
      (session) {
        if (session.cards == null || session.cards!.isEmpty) {
          emit(const StudySessionEmpty('No cards due for review'));
        } else {
          final cards = session.cards!;
          final startIndex = cards.isEmpty
              ? 0
              : session.currentIndex.clamp(0, cards.length - 1).toInt();
          final startedState = StudySessionStarted(
            session: session,
            cards: cards,
            currentCardIndex: startIndex,
            showAnswer: false,
          );
          emit(startedState);
        }
      },
    );
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

    result.fold(
      (failure) {
        emit(StudySessionError(failure.message));
        emit(currentState.copyWith());
      },
      (_) {
        final totalCards = currentState.session.meta.totalCards != 0
            ? currentState.session.meta.totalCards
            : currentState.cards.length;
        final reviewedRaw = currentState.currentCardIndex + 1;
        final boundedReviewed = totalCards == 0
            ? 0
            : reviewedRaw > totalCards
            ? totalCards
            : reviewedRaw;
        final remaining = totalCards - boundedReviewed;
        final progress = totalCards == 0 ? 0.0 : boundedReviewed / totalCards;
        final boundedProgress = progress.clamp(0.0, 1.0).toDouble();
        final isCorrect = event.rating >= 2;

        final updatedSession = currentState.session.copyWith(
          cardsStudied: currentState.session.cardsStudied + 1,
          cardsCorrect: isCorrect
              ? currentState.session.cardsCorrect + 1
              : currentState.session.cardsCorrect,
          cardsWrong: isCorrect
              ? currentState.session.cardsWrong
              : currentState.session.cardsWrong + 1,
          meta: currentState.session.meta.copyWith(
            totalCards: totalCards,
            reviewed: boundedReviewed,
            remaining: remaining < 0 ? 0 : remaining,
            progress: boundedProgress,
          ),
        );

        // Update current card info if API returned fresh data
        if (currentState.hasMoreCards) {
          final nextState = currentState.copyWith(
            session: updatedSession,
            currentCardIndex: currentState.currentCardIndex + 1,
            showAnswer: false,
          );
          emit(nextState);
        } else {
          emit(currentState.copyWith(session: updatedSession));
          // Complete session
          add(CompleteSessionEvent(currentState.session.id));
        }
      },
    );
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

  Future<void> _onResumeSession(
    ResumeExistingSessionEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    emit(const StudySessionLoading());

    final resumeResult = await resumeSession(event.sessionId);

    await resumeResult.fold(
      (failure) async {
        emit(StudySessionError(failure.message));
        if (event.deckId != null) {
          add(InitializeStudySessionEvent(event.deckId!));
        }
      },
      (resumedSession) async {
        final hasCards =
            resumedSession.cards != null && resumedSession.cards!.isNotEmpty;
        if (hasCards) {
          final cards = resumedSession.cards!;
          final index = cards.isEmpty
              ? 0
              : resumedSession.currentIndex.clamp(0, cards.length - 1).toInt();
          emit(
            StudySessionStarted(
              session: resumedSession,
              cards: cards,
              currentCardIndex: index,
              showAnswer: false,
            ),
          );
        } else {
          final detailResult = await getSessionDetail(event.sessionId);
          detailResult.fold(
            (failure) {
              emit(StudySessionError(failure.message));
              if (event.deckId != null) {
                add(InitializeStudySessionEvent(event.deckId!));
              }
            },
            (detail) {
              final detailCards = detail.cards ?? const <FlashcardCard>[];
              final index = detailCards.isEmpty
                  ? 0
                  : detail.currentIndex
                        .clamp(0, detailCards.length - 1)
                        .toInt();
              emit(
                StudySessionStarted(
                  session: detail,
                  cards: detailCards,
                  currentCardIndex: index,
                  showAnswer: false,
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _onPauseSession(
    PauseCurrentSessionEvent event,
    Emitter<StudySessionState> emit,
  ) async {
    final previousState = state;
    emit(const StudySessionLoading());

    final result = await pauseSession(event.sessionId);

    await result.fold(
      (failure) async {
        emit(StudySessionError(failure.message));

        if (previousState is StudySessionStarted) {
          emit(previousState.copyWith());
        } else if (previousState is StudySessionSetup) {
          emit(
            StudySessionSetup(
              deckId: previousState.deckId,
              activeSessions: previousState.activeSessions,
            ),
          );
        } else {
          emit(const StudySessionInitial());
        }
      },
      (session) async {
        final activeResult = await getActiveSessions(deckId: session.deckId);
        activeResult.fold(
          (failure) => emit(StudySessionError(failure.message)),
          (sessions) => emit(
            StudySessionSetup(deckId: session.deckId, activeSessions: sessions),
          ),
        );
      },
    );
  }
}
