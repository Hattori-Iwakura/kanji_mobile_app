import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/flashcard_deck_bloc.dart';
import '../bloc/flashcard_deck_event.dart';
import '../bloc/flashcard_deck_state.dart';
import '../bloc/study_session_bloc.dart';
import 'create_deck_page.dart';
import 'deck_detail_page.dart';
import 'study_session_page.dart';

class FlashcardDeckListPage extends StatefulWidget {
  const FlashcardDeckListPage({Key? key}) : super(key: key);

  @override
  State<FlashcardDeckListPage> createState() => _FlashcardDeckListPageState();
}

class _FlashcardDeckListPageState extends State<FlashcardDeckListPage> {
  @override
  void initState() {
    super.initState();
    context.read<FlashcardDeckBloc>().add(const LoadUserDecksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Flashcard Decks'),
        backgroundColor: Colors.grey[900],
      ),
      body: BlocBuilder<FlashcardDeckBloc, FlashcardDeckState>(
        builder: (context, state) {
          if (state is FlashcardDeckLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is FlashcardDeckError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FlashcardDeckBloc>().add(
                        const LoadUserDecksEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is FlashcardDeckLoaded) {
            if (state.decks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.style_outlined,
                      color: Colors.grey,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No flashcard decks yet',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your first deck to start learning',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCreateDeck(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Deck'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FlashcardDeckBloc>().add(
                  const RefreshDecksEvent(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.decks.length,
                itemBuilder: (context, index) {
                  final deck = state.decks[index];
                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _navigateToDeckDetail(context, deck.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    deck.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (deck.sourceType == 'kanji_list')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'From List',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (deck.description != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                deck.description!,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStatChip(
                                  Icons.style,
                                  '${deck.totalCards} cards',
                                  Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                if (deck.cardsNew > 0)
                                  _buildStatChip(
                                    Icons.fiber_new,
                                    '${deck.cardsNew} new',
                                    Colors.green,
                                  ),
                                const SizedBox(width: 8),
                                if (deck.cardsDue > 0)
                                  _buildStatChip(
                                    Icons.schedule,
                                    '${deck.cardsDue} due',
                                    Colors.orange,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _navigateToStudySession(context, deck.id),
                                  icon: const Icon(Icons.play_arrow, size: 20),
                                  label: const Text('Study'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showDeleteDialog(
                                    context,
                                    deck.id,
                                    deck.name,
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateDeck(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _navigateToCreateDeck(BuildContext context) {
    final bloc = context.read<FlashcardDeckBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BlocProvider.value(value: bloc, child: const CreateDeckPage()),
      ),
    ).then((_) {
      // Refresh deck list after creating
      bloc.add(const LoadUserDecksEvent());
    });
  }

  void _navigateToDeckDetail(BuildContext context, int deckId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeckDetailPage(deckId: deckId)),
    );
  }

  void _navigateToStudySession(BuildContext context, int deckId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<StudySessionBloc>(),
          child: StudySessionPage(deckId: deckId),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int deckId, String deckName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Delete Deck', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$deckName"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FlashcardDeckBloc>().add(DeleteDeckEvent(deckId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
