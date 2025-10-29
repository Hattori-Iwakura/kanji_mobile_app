import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'dart:async';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../../domain/entities/next_card.dart';

class StudySessionPage extends StatefulWidget {
  final int sessionId;

  const StudySessionPage({super.key, required this.sessionId});

  @override
  State<StudySessionPage> createState() => _StudySessionPageState();
}

class _StudySessionPageState extends State<StudySessionPage> {
  late FlipCardController _flipController;
  NextCard? _currentCard;
  DateTime? _cardStartTime;
  int _cardsReviewed = 0;
  int _totalCards = 0;
  bool _showRatingButtons = false;
  bool _isCardFlipped = false;
  bool _hasReviewedCurrentCard = false;

  @override
  void initState() {
    super.initState();
    _flipController = FlipCardController();
    _loadNextCard();
  }

  void _loadNextCard() {
    setState(() {
      _cardStartTime = DateTime.now();
      _showRatingButtons = false; // Reset rating buttons
      _isCardFlipped = false; // Reset flip state
      _hasReviewedCurrentCard = false; // Reset review state
      // Create new flip controller to ensure clean state
      _flipController = FlipCardController();
    });
    context.read<FlashcardBloc>().add(LoadNextCardEvent(widget.sessionId));
  }

  double _getTimeSpent() {
    if (_cardStartTime == null) return 0;
    return DateTime.now().difference(_cardStartTime!).inMilliseconds / 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F14),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071126), Color(0xFF0B0F14)],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<FlashcardBloc, FlashcardState>(
              listener: (context, state) {
                if (state is FlashcardError) {
                  if (state.message.contains('No more cards')) {
                    _completeSession();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else if (state is NextCardLoaded) {
                  setState(() {
                    _currentCard = state.card;
                    _totalCards = state.card.totalCards;
                    _cardsReviewed = state.card.currentCard - 1;
                  });
                } else if (state is CardReviewed) {
                  // Don't auto-load next card, let user decide when to continue
                  setState(() {
                    _hasReviewedCurrentCard = true;
                  });
                } else if (state is SessionCompleted) {
                  _showCompletionDialog(state.session);
                }
              },
              builder: (context, state) {
                if (state is FlashcardLoading && _currentCard == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                if (_currentCard == null) {
                  return const Center(
                    child: Text(
                      'Loading card...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Custom App Bar
                    _buildAppBar(),

                    // Progress Bar
                    _buildProgressBar(),

                    const SizedBox(height: 20),

                    // Flip Card
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildFlipCard(),
                        ),
                      ),
                    ),

                    // Action Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () async {
                if (await _showExitDialog()) {
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.tealAccent, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            'Study Session',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalCards > 0 ? _cardsReviewed / _totalCards : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Card $_cardsReviewed / $_totalCards',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (_currentCard?.isNew ?? false)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.tealAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlipCard() {
    return FlipCard(
      controller: _flipController,
      direction: FlipDirection.HORIZONTAL,
      speed: 500,
      onFlip: () {
        setState(() {
          _isCardFlipped = !_isCardFlipped;
        });
      },
      front: _buildCardFront(),
      back: _buildCardBack(),
    );
  }

  Widget _buildCardFront() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400, maxHeight: 500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.tealAccent.withOpacity(0.3),
            const Color(0xFF00BFA5).withOpacity(0.2),
          ],
        ),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _flipController.toggleCard(),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'What is the meaning of:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _currentCard!.character,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.tealAccent, blurRadius: 30)],
                  ),
                ),
                const SizedBox(height: 32),
                Icon(
                  Icons.help_outline,
                  size: 48,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Think about the answer...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 20,
                      color: Colors.tealAccent.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to reveal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.tealAccent.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      constraints: const BoxConstraints(minHeight: 400, maxHeight: 500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.tealAccent.withOpacity(0.3),
            Colors.greenAccent.withOpacity(0.2),
          ],
        ),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _flipController.toggleCard(),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentCard!.character,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentCard!.meaning,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                if (_currentCard!.onyomi.isNotEmpty) ...[
                  _buildReadingRow('音読み', _currentCard!.onyomi),
                  const SizedBox(height: 12),
                ],
                if (_currentCard!.kunyomi.isNotEmpty) ...[
                  _buildReadingRow('訓読み', _currentCard!.kunyomi),
                ],
                if (!_showRatingButtons) ...[
                  const SizedBox(height: 32),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        size: 20,
                        color: Colors.tealAccent.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap below to rate your knowledge',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.tealAccent.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingRow(String label, String reading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
        ),
        Text(
          reading,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    // When showing front - no buttons (tap card to flip)
    if (!_isCardFlipped) {
      return const SizedBox(height: 56); // Keep spacing consistent
    }

    // After reviewed - show Next Card button
    if (_hasReviewedCurrentCard) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loadNextCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Next Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // When showing back but not ready to rate - show "Rate" button
    if (!_showRatingButtons) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showRatingButtons = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  'Rate Your Knowledge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Rating buttons when ready to rate
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQualityButton(
              quality: 1,
              label: 'Again',
              color: Colors.red.shade400,
              icon: Icons.close,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQualityButton(
              quality: 2,
              label: 'Hard',
              color: Colors.orange.shade400,
              icon: Icons.sentiment_neutral,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQualityButton(
              quality: 4,
              label: 'Good',
              color: Colors.lightGreen.shade400,
              icon: Icons.sentiment_satisfied,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQualityButton(
              quality: 5,
              label: 'Easy',
              color: Colors.green.shade600,
              icon: Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityButton({
    required int quality,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: () => _reviewCard(quality),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _reviewCard(int quality) {
    if (_currentCard == null) return;

    final timeSpent = _getTimeSpent();
    context.read<FlashcardBloc>().add(
      ReviewCardEvent(
        sessionId: widget.sessionId,
        cardId: _currentCard!.cardId,
        quality: quality,
        timeSpent: timeSpent,
      ),
    );

    setState(() {
      _cardsReviewed++;
    });
  }

  void _completeSession() {
    context.read<FlashcardBloc>().add(CompleteSessionEvent(widget.sessionId));
  }

  void _showCompletionDialog(dynamic session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.tealAccent.withOpacity(0.3), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.amber,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Session Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatRow('Cards Reviewed', '${session.cardsReviewed}'),
              _buildStatRow('Correct', '${session.correctAnswers}'),
              _buildStatRow('Incorrect', '${session.incorrectAnswers}'),
              _buildStatRow('Accuracy', '${session.accuracy}%'),
              if (session.cardsMastered != null)
                _buildStatRow('Cards Mastered', '${session.cardsMastered}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to deck detail
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: const Color(0xFF1A1F2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Exit Study Session?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your progress will be saved, but you should complete the session for best results.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _completeSession();
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }
}
