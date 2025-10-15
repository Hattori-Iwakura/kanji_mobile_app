import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/study_session_bloc.dart';
import '../bloc/study_session_event.dart';
import '../bloc/study_session_state.dart';
import '../../../../injection_container.dart' as di;

class StudySessionPage extends StatelessWidget {
  final int deckId;

  const StudySessionPage({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<StudySessionBloc>()
            ..add(StartStudySessionEvent(deckId: deckId, maxCards: 20)),
      child: _StudySessionView(deckId: deckId),
    );
  }
}

class _StudySessionView extends StatefulWidget {
  final int deckId;

  const _StudySessionView({required this.deckId});

  @override
  State<_StudySessionView> createState() => _StudySessionViewState();
}

class _StudySessionViewState extends State<_StudySessionView> {
  bool _showAnswer = false;
  DateTime? _cardStartTime;

  @override
  void initState() {
    super.initState();
    _cardStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Study Session'),
        backgroundColor: Colors.grey[900],
        actions: [
          BlocBuilder<StudySessionBloc, StudySessionState>(
            builder: (context, state) {
              if (state is StudySessionStarted) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${state.currentCardIndex + 1}/${state.cards.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<StudySessionBloc, StudySessionState>(
        listener: (context, state) {
          if (state is StudySessionStarted) {
            setState(() {
              _showAnswer = state.showAnswer;
              _cardStartTime = DateTime.now();
            });
          }

          if (state is StudySessionCompleted) {
            _showCompletionDialog(context, state);
          }

          if (state is StudySessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StudySessionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is StudySessionEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All caught up!',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Decks'),
                  ),
                ],
              ),
            );
          }

          if (state is StudySessionStarted) {
            final card = state.currentCard;

            return Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: (state.currentCardIndex + 1) / state.cards.length,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Card container
                          GestureDetector(
                            onTap: () {
                              if (!_showAnswer) {
                                setState(() {
                                  _showAnswer = true;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 300),
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Front (Kanji character)
                                  Text(
                                    card.frontContent,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 80,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  if (_showAnswer) ...[
                                    const SizedBox(height: 24),
                                    const Divider(color: Colors.grey),
                                    const SizedBox(height: 24),

                                    // Back (meanings and readings)
                                    if (card.backContent['meanings'] != null)
                                      Text(
                                        card.backContent['meanings'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                    const SizedBox(height: 16),

                                    if (card.backContent['onyomi'] != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'On: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            card.backContent['onyomi'],
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 8),

                                    if (card.backContent['kunyomi'] != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Kun: ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            card.backContent['kunyomi'],
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ] else ...[
                                    const SizedBox(height: 24),
                                    const Icon(
                                      Icons.touch_app,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap to reveal',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Rating buttons (only show when answer is revealed)
                          if (_showAnswer)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildRatingButton(
                                  context,
                                  'Again',
                                  Icons.close,
                                  Colors.red,
                                  0,
                                  state.session.id,
                                  card.id,
                                ),
                                _buildRatingButton(
                                  context,
                                  'Hard',
                                  Icons.sentiment_dissatisfied,
                                  Colors.orange,
                                  1,
                                  state.session.id,
                                  card.id,
                                ),
                                _buildRatingButton(
                                  context,
                                  'Good',
                                  Icons.sentiment_satisfied,
                                  Colors.blue,
                                  2,
                                  state.session.id,
                                  card.id,
                                ),
                                _buildRatingButton(
                                  context,
                                  'Easy',
                                  Icons.sentiment_very_satisfied,
                                  Colors.green,
                                  3,
                                  state.session.id,
                                  card.id,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        },
      ),
    );
  }

  Widget _buildRatingButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    int rating,
    int sessionId,
    int cardId,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        final timeSpent = _cardStartTime != null
            ? DateTime.now().difference(_cardStartTime!).inSeconds
            : 0;

        context.read<StudySessionBloc>().add(
          ReviewCardEvent(
            sessionId: sessionId,
            cardId: cardId,
            rating: rating,
            timeSpent: timeSpent,
          ),
        );

        setState(() {
          _showAnswer = false;
        });
      },
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    StudySessionCompleted state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          '🎉 Session Complete!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Great work!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Cards Studied', '${state.session.cardsStudied}'),
            _buildStatRow(
              'Correct',
              '${state.session.cardsCorrect}',
              Colors.green,
            ),
            _buildStatRow('Wrong', '${state.session.cardsWrong}', Colors.red),
            _buildStatRow(
              'Time',
              '${(state.session.totalTime / 60).toStringAsFixed(1)} min',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
