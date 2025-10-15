import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';
import 'study_session_page.dart';
import '../../../../injection_container.dart' as di;

class DeckDetailPage extends StatelessWidget {
  final int deckId;

  const DeckDetailPage({Key? key, required this.deckId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<DeckDetailBloc>()..add(LoadDeckDetailEvent(deckId)),
      child: _DeckDetailView(deckId: deckId),
    );
  }
}

class _DeckDetailView extends StatelessWidget {
  final int deckId;

  const _DeckDetailView({required this.deckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Deck Detail'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCardDialog(context),
            tooltip: 'Add Card',
          ),
        ],
      ),
      body: BlocBuilder<DeckDetailBloc, DeckDetailState>(
        builder: (context, state) {
          if (state is DeckDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is DeckDetailError) {
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
                      context.read<DeckDetailBloc>().add(
                        LoadDeckDetailEvent(deckId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DeckDetailLoaded) {
            final deck = state.deck;

            return Column(
              children: [
                // Deck Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (deck.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          deck.description!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip(
                            Icons.style,
                            '${deck.totalCards} cards',
                            Colors.blue,
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: deck.totalCards > 0
                              ? () => _startStudy(context, deckId)
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Study'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cards List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Cards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${deck.totalCards})',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Cards will be shown here when backend provides them
                Expanded(
                  child: deck.totalCards == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.style_outlined,
                                size: 64,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No cards yet',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add cards',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: deck.totalCards,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.grey[850],
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                                title: Text(
                                  'Card ${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Kanji card',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _showDeleteCardDialog(context, index + 1),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final kanjiIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Add Card', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: kanjiIdController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Kanji ID',
            labelStyle: const TextStyle(color: Colors.grey),
            hintText: 'Enter kanji ID',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final kanjiId = int.tryParse(kanjiIdController.text);
              if (kanjiId != null) {
                context.read<DeckDetailBloc>().add(
                  AddCardToDeckEvent(deckId: deckId, kanjiId: kanjiId),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCardDialog(BuildContext context, int cardId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Delete Card', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this card?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DeckDetailBloc>().add(DeleteCardEvent(cardId));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startStudy(BuildContext context, int deckId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudySessionPage(deckId: deckId)),
    );
  }
}
