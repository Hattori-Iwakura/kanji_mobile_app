import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/study_session_bloc.dart';
import '../bloc/study_session_event.dart';
import '../bloc/study_session_state.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/study_session.dart';

class StudySessionPage extends StatelessWidget {
  final int deckId;

  const StudySessionPage({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<StudySessionBloc>()..add(InitializeStudySessionEvent(deckId)),
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
  final TextEditingController _maxCardsController = TextEditingController(
    text: '20',
  );
  String _selectedMode = 'mixed';
  bool _randomize = false;
  bool _includeNew = true;
  bool _includeDue = true;
  bool _includeHard = false;
  double _difficultyThreshold = 2;
  bool _resumeExisting = true;

  @override
  void initState() {
    super.initState();
    _cardStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _maxCardsController.dispose();
    super.dispose();
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
                final total = state.cards.length;
                final current = total == 0 ? 0 : state.currentCardIndex + 1;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '$current/$total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Pause session',
                      icon: const Icon(Icons.pause_circle_filled),
                      onPressed: () => context.read<StudySessionBloc>().add(
                        PauseCurrentSessionEvent(state.session.id),
                      ),
                    ),
                  ],
                );
              }

              if (state is StudySessionSetup) {
                return IconButton(
                  tooltip: 'Refresh sessions',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<StudySessionBloc>().add(
                    InitializeStudySessionEvent(state.deckId),
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
          if (state is StudySessionSetup) {
            setState(() {
              _showAnswer = false;
            });
          }

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

          if (state is StudySessionSetup) {
            return _buildSessionSetup(context, state);
          }

          if (state is StudySessionError) {
            return _buildErrorState(context, state);
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
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.read<StudySessionBloc>().add(
                      InitializeStudySessionEvent(widget.deckId),
                    ),
                    child: const Text('Adjust Session Options'),
                  ),
                ],
              ),
            );
          }

          if (state is StudySessionStarted) {
            // Safe check for cards
            if (state.cards.isEmpty) {
              return const Center(
                child: Text(
                  'No cards available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            // Safe check for current index
            if (state.currentCardIndex >= state.cards.length) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            final card = state.currentCard;
            final meta = state.session.meta;
            final settings = state.session.settings;
            final fallbackProgress = state.cards.isEmpty
                ? 0.0
                : (state.currentCardIndex + 1) / state.cards.length;
            final progressValue = meta.totalCards > 0
                ? meta.progress
                : fallbackProgress;
            final boundedProgress = progressValue.clamp(0.0, 1.0).toDouble();
            final minutesSpent = (state.session.totalTime / 60).toStringAsFixed(
              1,
            );
            final statusRaw = state.session.status;
            final statusLabel = statusRaw.isEmpty
                ? 'Active'
                : '${statusRaw[0].toUpperCase()}${statusRaw.substring(1).toLowerCase()}';

            return Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: boundedProgress,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            Icons.school,
                            '${meta.reviewed}/${meta.totalCards} reviewed',
                          ),
                          _buildChip(
                            Icons.pending_actions,
                            '${meta.remaining} remaining',
                          ),
                          _buildChip(Icons.timer, '$minutesSpent min spent'),
                          _buildChip(Icons.bolt, statusLabel),
                        ],
                      ),
                      if (settings != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(Icons.tune, 'Mode: ${settings.mode}'),
                            _buildChip(
                              Icons.shuffle,
                              settings.randomize ? 'Randomized' : 'Ordered',
                            ),
                            _buildChip(
                              Icons.fiber_new,
                              settings.includeNew
                                  ? 'New cards'
                                  : 'No new cards',
                            ),
                            _buildChip(
                              Icons.schedule,
                              settings.includeDue ? 'Due cards' : 'Skip due',
                            ),
                            _buildChip(
                              Icons.star,
                              settings.includeHard ? 'Hard focus' : 'Standard',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
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
                                        card.backContent['meanings'].toString(),
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
                                            card.backContent['onyomi']
                                                .toString(),
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
                                            card.backContent['kunyomi']
                                                .toString(),
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

  Widget _buildErrorState(BuildContext context, StudySessionError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              onPressed: () => context.read<StudySessionBloc>().add(
                InitializeStudySessionEvent(widget.deckId),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Decks'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSetup(BuildContext context, StudySessionSetup state) {
    final theme = Theme.of(context);
    final deckId = state.deckId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure Your Session',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fine-tune which cards you would like to study and how the session behaves.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          _buildSessionOptionsCard(theme),
          const SizedBox(height: 24),
          if (state.hasActiveSessions) ...[
            Text(
              'Active Sessions',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...state.activeSessions
                .map((session) => _buildActiveSessionCard(context, session))
                .toList(),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Session'),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    final maxCards = int.tryParse(
                      _maxCardsController.text.trim(),
                    );
                    final difficulty = _difficultyThreshold.round();

                    context.read<StudySessionBloc>().add(
                      StartStudySessionEvent(
                        deckId: deckId,
                        maxCards: maxCards == null || maxCards <= 0
                            ? null
                            : maxCards,
                        mode: _selectedMode,
                        randomize: _randomize,
                        includeNew: _includeNew,
                        includeDue: _includeDue,
                        includeHard: _includeHard,
                        difficultyThreshold: difficulty,
                        resumeExisting: _resumeExisting,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionOptionsCard(ThemeData theme) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Options',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxCardsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Maximum cards',
                labelStyle: const TextStyle(color: Colors.grey),
                helperText: 'Leave empty for all available cards',
                helperStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedMode,
              dropdownColor: Colors.grey[900],
              decoration: InputDecoration(
                labelText: 'Priority mode',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'mixed', child: Text('Mixed')),
                DropdownMenuItem(value: 'due', child: Text('Due first')),
                DropdownMenuItem(value: 'new', child: Text('New first')),
                DropdownMenuItem(value: 'hard', child: Text('Focus on hard')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedMode = value);
              },
            ),
            const SizedBox(height: 20),
            _buildToggle(
              title: 'Randomize order',
              value: _randomize,
              onChanged: (value) => setState(() => _randomize = value),
            ),
            _buildToggle(
              title: 'Include new cards',
              value: _includeNew,
              onChanged: (value) => setState(() => _includeNew = value),
            ),
            _buildToggle(
              title: 'Include due cards',
              value: _includeDue,
              onChanged: (value) => setState(() => _includeDue = value),
            ),
            _buildToggle(
              title: 'Include hard cards',
              value: _includeHard,
              onChanged: (value) => setState(() => _includeHard = value),
            ),
            _buildToggle(
              title: 'Resume existing session if available',
              value: _resumeExisting,
              onChanged: (value) => setState(() => _resumeExisting = value),
            ),
            const SizedBox(height: 12),
            Text(
              'Difficulty threshold: ${_difficultyThreshold.round()}',
              style: const TextStyle(color: Colors.white),
            ),
            Slider(
              value: _difficultyThreshold,
              min: 1,
              max: 5,
              divisions: 4,
              label: _difficultyThreshold.round().toString(),
              onChanged: (value) =>
                  setState(() => _difficultyThreshold = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }

  Widget _buildActiveSessionCard(BuildContext context, StudySession session) {
    final meta = session.meta;
    final theme = Theme.of(context);
    final progress = meta.progress.clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session #${session.id}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent% complete • ${meta.reviewed}/${meta.totalCards} reviewed',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip(Icons.list_alt, '${session.cardsTotal} cards'),
                _buildChip(
                  Icons.check_circle,
                  '${session.cardsCorrect} correct',
                ),
                _buildChip(
                  Icons.access_time,
                  '${(session.totalTime / 60).toStringAsFixed(1)} min',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
                onPressed: () => context.read<StudySessionBloc>().add(
                  ResumeExistingSessionEvent(session.id, deckId: widget.deckId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.blueGrey[100]),
      backgroundColor: Colors.grey[850],
      label: Text(label, style: const TextStyle(color: Colors.white)),
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
              context.read<StudySessionBloc>().add(
                InitializeStudySessionEvent(state.session.deckId),
              );
            },
            child: const Text('New Session'),
          ),
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
