import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard_card.dart';
import '../../domain/entities/study_session.dart';

abstract class StudySessionState extends Equatable {
  const StudySessionState();

  @override
  List<Object?> get props => [];
}

class StudySessionInitial extends StudySessionState {
  const StudySessionInitial();
}

class StudySessionLoading extends StudySessionState {
  const StudySessionLoading();
}

class StudySessionStarted extends StudySessionState {
  final StudySession session;
  final List<FlashcardCard> cards;
  final int currentCardIndex;
  final bool showAnswer;

  const StudySessionStarted({
    required this.session,
    required this.cards,
    this.currentCardIndex = 0,
    this.showAnswer = false,
  });

  FlashcardCard get currentCard => cards[currentCardIndex];
  bool get hasMoreCards => currentCardIndex < cards.length - 1;
  int get remainingCards => cards.length - currentCardIndex;

  StudySessionStarted copyWith({
    StudySession? session,
    List<FlashcardCard>? cards,
    int? currentCardIndex,
    bool? showAnswer,
  }) {
    return StudySessionStarted(
      session: session ?? this.session,
      cards: cards ?? this.cards,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      showAnswer: showAnswer ?? this.showAnswer,
    );
  }

  @override
  List<Object> get props => [session, cards, currentCardIndex, showAnswer];
}

class StudySessionReviewSubmitted extends StudySessionState {
  final Map<String, dynamic> reviewResult;
  final int currentCardIndex;
  final int totalCards;

  const StudySessionReviewSubmitted({
    required this.reviewResult,
    required this.currentCardIndex,
    required this.totalCards,
  });

  @override
  List<Object> get props => [reviewResult, currentCardIndex, totalCards];
}

class StudySessionCompleted extends StudySessionState {
  final StudySession session;

  const StudySessionCompleted(this.session);

  @override
  List<Object> get props => [session];
}

class StudySessionEmpty extends StudySessionState {
  final String message;

  const StudySessionEmpty(this.message);

  @override
  List<Object> get props => [message];
}

class StudySessionError extends StudySessionState {
  final String message;

  const StudySessionError(this.message);

  @override
  List<Object> get props => [message];
}
