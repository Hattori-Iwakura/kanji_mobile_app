import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';
import '../bloc/flashcard_state.dart';
import '../widgets/deck_card.dart';
import '../widgets/create_deck_dialog.dart';
import 'study_session_page.dart';

/// Page displaying all flashcard decks
class FlashcardDeckListPage extends StatelessWidget {
  const FlashcardDeckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FlashcardBloc>()..add(LoadDecksEvent()),
      child: const _FlashcardDeckListView(),
    );
  }
}

class _FlashcardDeckListView extends StatelessWidget {
  const _FlashcardDeckListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Flashcard Decks',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateDeckDialog(context),
            tooltip: 'Create New Deck',
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
          } else if (state is DeckCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Deck "${state.deck.name}" created!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DeckDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deck deleted'),
                backgroundColor: Colors.orange,
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

          if (state is DecksLoaded) {
            if (!state.hasDecks) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FlashcardBloc>().add(LoadDecksEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats summary
                  _buildStatsSummary(state.decks),
                  const SizedBox(height: 24),

                  // Decks with cards to review
                  if (state.decksWithReview.isNotEmpty) ...[
                    const Text(
                      'Ready to Study',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.decksWithReview.map(
                      (deck) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DeckCard(
                          deck: deck,
                          onTap: () => _startStudySession(context, deck),
                          onDelete: () =>
                              _showDeleteConfirmation(context, deck),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // All decks
                  const Text(
                    'All Decks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.decks.map(
                    (deck) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeckCard(
                        deck: deck,
                        onTap: () => _startStudySession(context, deck),
                        onDelete: () => _showDeleteConfirmation(context, deck),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Flashcard Decks',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first deck to start learning kanji with spaced repetition!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateDeckDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Deck'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(List<FlashcardDeck> decks) {
    final totalCards = decks.fold<int>(0, (sum, deck) => sum + deck.totalCards);
    final dueCards = decks.fold<int>(0, (sum, deck) => sum + deck.dueCards);
    final newCards = decks.fold<int>(0, (sum, deck) => sum + deck.newCards);
    final masteredCards = decks.fold<int>(
      0,
      (sum, deck) => sum + deck.masteredCards,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total', totalCards, Icons.style),
              _buildStatItem('Due', dueCards, Icons.alarm, Colors.orange),
              _buildStatItem('New', newCards, Icons.new_releases, Colors.blue),
              _buildStatItem(
                'Mastered',
                masteredCards,
                Icons.star,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    int value,
    IconData icon, [
    Color? color,
  ]) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _showCreateDeckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<FlashcardBloc>(),
        child: const CreateDeckDialog(),
      ),
    );
  }

  void _startStudySession(BuildContext context, FlashcardDeck deck) {
    if (!deck.hasCardsToReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No cards to review in this deck'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudySessionPage(deckId: deck.id, deckName: deck.name),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, FlashcardDeck deck) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Delete Deck?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${deck.name}"? This will delete all ${deck.totalCards} cards in this deck.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FlashcardBloc>().add(DeleteDeckEvent(deck.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
