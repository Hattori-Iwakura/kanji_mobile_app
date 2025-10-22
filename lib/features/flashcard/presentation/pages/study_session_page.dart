import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/flashcard.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import 'session_results_page.dart';

/// Page for studying flashcards with flip animation
class StudySessionPage extends StatefulWidget {
  final String deckId;
  final String deckName;

  const StudySessionPage({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  late DateTime _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FlashcardBloc>()..add(StartStudySessionEvent(widget.deckId)),
      child: _StudySessionView(
        deckName: widget.deckName,
        deckId: widget.deckId,
        sessionStartTime: _sessionStartTime,
      ),
    );
  }
}

class _StudySessionView extends StatelessWidget {
  final String deckName;
  final String deckId;
  final DateTime sessionStartTime;

  const _StudySessionView({
    required this.deckName,
    required this.deckId,
    required this.sessionStartTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(deckName, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _showExitConfirmation(context),
            tooltip: 'Exit Study Session',
          ),
        ],
      ),
      body: BlocConsumer<FlashcardBloc, FlashcardState>(
        listener: (context, state) {
          if (state is FlashcardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pop(context);
          } else if (state is StudySessionCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SessionResultsPage(progress: state.progress),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FlashcardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is StudySessionActive) {
            if (state.isComplete) {
              // Auto-end session when complete
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final duration = DateTime.now().difference(sessionStartTime);
                context.read<FlashcardBloc>().add(
                  EndStudySessionEvent(
                    deckId: deckId,
                    cardsStudied: state.cardsStudied,
                    cardsCorrect: state.cardsCorrect,
                    cardsIncorrect: state.cardsIncorrect,
                    studyDuration: duration.inSeconds,
                  ),
                );
              });
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final currentCard = state.currentCard;
            if (currentCard == null) {
              return const Center(
                child: Text(
                  'No cards to study',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Column(
              children: [
                // Progress bar
                _buildProgressBar(state),

                // Stats row
                _buildStatsRow(state),

                // Flashcard with flip animation
                Expanded(
                  child: Center(
                    child: _FlipCard(
                      card: currentCard,
                      showAnswer: state.showAnswer,
                      onFlip: () =>
                          context.read<FlashcardBloc>().add(FlipCardEvent()),
                    ),
                  ),
                ),

                // Quality rating buttons
                if (state.showAnswer) _buildQualityButtons(context, state),

                const SizedBox(height: 16),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressBar(StudySessionActive state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card ${state.currentIndex + 1} of ${state.cards.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '${state.progressPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progressPercentage / 100,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(StudySessionActive state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Correct',
            value: state.cardsCorrect,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.cancel,
            label: 'Incorrect',
            value: state.cardsIncorrect,
            color: Colors.red,
          ),
          _buildStatItem(
            icon: Icons.percent,
            label: 'Accuracy',
            value: state.accuracy.toStringAsFixed(0),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQualityButtons(BuildContext context, StudySessionActive state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'How well did you remember?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildQualityButton(
                context,
                state,
                quality: 0,
                label: 'Blackout',
                color: Colors.red.shade900,
                icon: Icons.close,
              ),
              _buildQualityButton(
                context,
                state,
                quality: 1,
                label: 'Wrong',
                color: Colors.red.shade700,
                icon: Icons.thumb_down,
              ),
              _buildQualityButton(
                context,
                state,
                quality: 2,
                label: 'Hard',
                color: Colors.orange.shade700,
                icon: Icons.sentiment_dissatisfied,
              ),
              _buildQualityButton(
                context,
                state,
                quality: 3,
                label: 'Good',
                color: Colors.yellow.shade700,
                icon: Icons.sentiment_neutral,
              ),
              _buildQualityButton(
                context,
                state,
                quality: 4,
                label: 'Easy',
                color: Colors.green.shade600,
                icon: Icons.sentiment_satisfied,
              ),
              _buildQualityButton(
                context,
                state,
                quality: 5,
                label: 'Perfect',
                color: Colors.green.shade800,
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityButton(
    BuildContext context,
    StudySessionActive state, {
    required int quality,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final currentCard = state.currentCard;
    if (currentCard == null) return const SizedBox.shrink();

    return ElevatedButton(
      onPressed: () {
        context.read<FlashcardBloc>().add(
          AnswerCardEvent(cardId: currentCard.id, quality: quality),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          Text('($quality)', style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Exit Study Session?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your progress will not be saved if you exit now.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Studying'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

/// Flip card widget with animation
class _FlipCard extends StatefulWidget {
  final Flashcard card;
  final bool showAnswer;
  final VoidCallback onFlip;

  const _FlipCard({
    required this.card,
    required this.showAnswer,
    required this.onFlip,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnswer != oldWidget.showAnswer) {
      if (widget.showAnswer) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * math.pi;
        final isBack = angle > math.pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: GestureDetector(
            onTap: widget.onFlip,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(isBack ? math.pi : 0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isBack ? 'Answer' : 'Question',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Center(
                            child: Text(
                              isBack ? widget.card.back : widget.card.front,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Noto Sans JP',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Icon(
                          Icons.touch_app,
                          color: Colors.white.withOpacity(0.3),
                          size: 32,
                        ),
                        Text(
                          'Tap to ${isBack ? 'see question' : 'reveal answer'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
