import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';

/// Simple study session for flashcard deck
/// Shows cards one by one with flip animation
class FlashcardStudyPage extends StatelessWidget {
  final int deckId;

  const FlashcardStudyPage({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<FlashcardBloc>()..add(LoadDeckByIdEvent(deckId)),
      child: const _StudyView(),
    );
  }
}

class _StudyView extends StatefulWidget {
  const _StudyView();

  @override
  State<_StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<_StudyView> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  int _correctCount = 0;
  int _wrongCount = 0;

  void _nextCard() {
    final state = context.read<FlashcardBloc>().state;
    if (state is DeckDetailLoaded) {
      if (_currentIndex < state.deck.totalCards - 1) {
        setState(() {
          _currentIndex++;
          _showAnswer = false;
        });
      } else {
        _showCompletionDialog();
      }
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
    }
  }

  void _flipCard() {
    setState(() => _showAnswer = !_showAnswer);
  }

  void _markCorrect() {
    setState(() => _correctCount++);
    _nextCard();
  }

  void _markWrong() {
    setState(() => _wrongCount++);
    _nextCard();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Study Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Cards: ${_correctCount + _wrongCount}'),
            const SizedBox(height: 8),
            Text(
              '✅ Correct: $_correctCount',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              '❌ Wrong: $_wrongCount',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${_correctCount + _wrongCount > 0 ? ((_correctCount / (_correctCount + _wrongCount)) * 100).toStringAsFixed(1) : 0}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to deck list
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _showAnswer = false;
                _correctCount = 0;
                _wrongCount = 0;
              });
              Navigator.pop(context);
            },
            child: const Text('Study Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text('${_correctCount + _wrongCount} cards'),
              avatar: const Icon(Icons.check_circle, size: 18),
            ),
          ),
        ],
      ),
      body: BlocBuilder<FlashcardBloc, FlashcardState>(
        builder: (context, state) {
          if (state is FlashcardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FlashcardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is DeckDetailLoaded) {
            final deck = state.deck;

            if (deck.totalCards == 0) {
              return const Center(child: Text('This deck has no cards'));
            }

            // Note: In real implementation, you'd load actual cards from deck
            // For now, showing placeholder
            return Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (deck.totalCards > 0)
                      ? (_currentIndex + 1) / deck.totalCards
                      : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),

                const SizedBox(height: 16),

                // Card counter
                Text(
                  'Card ${_currentIndex + 1} of ${deck.totalCards}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Flashcard
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: Card(
                      margin: const EdgeInsets.all(24),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _showAnswer
                                ? [Colors.green[400]!, Colors.green[600]!]
                                : [Colors.blue[400]!, Colors.blue[600]!],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showAnswer ? 'ANSWER' : 'QUESTION',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Placeholder - replace with actual card data
                            Text(
                              _showAnswer
                                  ? 'Meaning / Reading'
                                  : 'Kanji Character',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Icon(
                              Icons.touch_app,
                              color: Colors.white70,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to flip',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                if (_showAnswer)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _markWrong,
                          icon: const Icon(Icons.close),
                          label: const Text('Wrong'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _markCorrect,
                          icon: const Icon(Icons.check),
                          label: const Text('Correct'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0 ? _previousCard : null,
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 32,
                      ),
                      Text(
                        '✅ $_correctCount  ❌ $_wrongCount',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextCard,
                        icon: const Icon(Icons.arrow_forward),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
