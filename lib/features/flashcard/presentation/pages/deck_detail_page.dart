import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/flashcard_deck_bloc.dart';
import '../bloc/flashcard_deck_event.dart';
import '../bloc/flashcard_deck_state.dart';
import '../widgets/flashcard_card_widget.dart';
import 'edit_deck_page.dart';
import 'study_session_page.dart';

/// Page displaying details of a single flashcard deck
class DeckDetailPage extends StatelessWidget {
  final int deckId;

  const DeckDetailPage({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FlashcardDeckBloc>()..add(LoadFlashcardDeckByIdEvent(deckId)),
      child: const _DeckDetailView(),
    );
  }
}

class _DeckDetailView extends StatelessWidget {
  const _DeckDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deck Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<FlashcardDeckBloc, FlashcardDeckState>(
            builder: (context, state) {
              if (state is FlashcardDeckLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditDeckPage(deck: state.deck),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          // Reload deck details
                          context.read<FlashcardDeckBloc>().add(
                            LoadFlashcardDeckByIdEvent(state.deck.id),
                          );
                        }
                      });
                    } else if (value == 'delete') {
                      _confirmDelete(context, state.deck.id, state.deck.name);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Deck'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete Deck',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<FlashcardDeckBloc, FlashcardDeckState>(
        listener: (context, state) {
          if (state is FlashcardDeckDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Deck deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is CardRemovedFromDeck) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Card removed from deck'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload deck
            context.read<FlashcardDeckBloc>().add(
              LoadFlashcardDeckByIdEvent(state.deck.id),
            );
          } else if (state is FlashcardDeckError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FlashcardDeckLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is FlashcardDeckLoaded) {
            final deck = state.deck;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FlashcardDeckBloc>().add(
                  LoadFlashcardDeckByIdEvent(deck.id),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deck header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.style,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  deck.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (deck.description != null &&
                              deck.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              deck.description!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.layers,
                                label: '${deck.totalCards} cards',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: deck.isPublic ? Icons.public : Icons.lock,
                                label: deck.isPublic ? 'Public' : 'Private',
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.person,
                                label: deck.userName,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cards section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cards in Deck',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${deck.cards.length} total',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Cards list
                    if (deck.cards.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No cards in this deck yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add kanji cards to start studying',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deck.cards.length,
                        itemBuilder: (context, index) {
                          final card = deck.cards[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FlashcardCardWidget(
                              card: card,
                              showRemoveButton: true,
                              onRemove: () => _confirmRemoveCard(
                                context,
                                deck.id,
                                card.kanjiId,
                                card.kanji.character,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Text(
              'Failed to load deck details',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<FlashcardDeckBloc, FlashcardDeckState>(
        builder: (context, state) {
          if (state is FlashcardDeckLoaded && state.deck.cards.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () {
                // Navigate to study session
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudySessionPage(
                      deckId: state.deck.id.toString(),
                      deckName: state.deck.name,
                    ),
                  ),
                ).then((_) {
                  // Reload deck after study session
                  context.read<FlashcardDeckBloc>().add(
                    LoadFlashcardDeckByIdEvent(state.deck.id),
                  );
                });
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Practice'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int deckId, String deckName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: Text(
          'Are you sure you want to delete "$deckName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FlashcardDeckBloc>().add(
                DeleteFlashcardDeckEvent(deckId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveCard(
    BuildContext context,
    int deckId,
    int kanjiId,
    String kanjiChar,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Card?'),
        content: Text('Remove "$kanjiChar" from this deck?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FlashcardDeckBloc>().add(
                RemoveCardFromDeckEvent(deckId: deckId, kanjiId: kanjiId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Info chip widget for deck header
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
