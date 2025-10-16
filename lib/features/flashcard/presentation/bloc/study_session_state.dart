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

class StudySessionSetup extends StudySessionState {
  final int deckId;
  final List<StudySession> activeSessions;

  const StudySessionSetup({
    required this.deckId,
    this.activeSessions = const [],
  });

  bool get hasActiveSessions => activeSessions.isNotEmpty;

  @override
  List<Object> get props => [deckId, activeSessions];
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

  FlashcardCard get currentCard {
    if (cards.isEmpty || currentCardIndex >= cards.length) {
      throw StateError('No card available at index $currentCardIndex');
    }
    return cards[currentCardIndex];
  }

  bool get hasMoreCards => currentCardIndex < cards.length - 1;
  int get remainingCards {
    final remaining = cards.length - currentCardIndex - 1;
    return remaining < 0 ? 0 : remaining;
  }

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
