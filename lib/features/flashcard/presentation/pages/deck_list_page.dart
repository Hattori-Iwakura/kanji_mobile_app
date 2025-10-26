import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/flashcard_deck_bloc.dart';
import '../bloc/flashcard_deck_event.dart';
import '../bloc/flashcard_deck_state.dart';
import '../widgets/flashcard_deck_card.dart';
import 'create_deck_page.dart';
import 'deck_detail_page.dart';
import 'edit_deck_page.dart';

/// Page displaying list of all flashcard decks
class DeckListPage extends StatelessWidget {
  const DeckListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<FlashcardDeckBloc>()..add(const LoadFlashcardDecksEvent()),
      child: const _DeckListView(),
    );
  }
}

class _DeckListView extends StatefulWidget {
  const _DeckListView();

  @override
  State<_DeckListView> createState() => _DeckListViewState();
}

class _DeckListViewState extends State<_DeckListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Flashcard Decks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search decks...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          context.read<FlashcardDeckBloc>().add(
                            const LoadFlashcardDecksEvent(),
                          );
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchQuery) {
                    context.read<FlashcardDeckBloc>().add(
                      LoadFlashcardDecksEvent(
                        search: value.isEmpty ? null : value,
                      ),
                    );
                  }
                });
              },
            ),
          ),

          // Deck list
          Expanded(
            child: BlocConsumer<FlashcardDeckBloc, FlashcardDeckState>(
              listener: (context, state) {
                if (state is FlashcardDeckDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deck deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload list
                  context.read<FlashcardDeckBloc>().add(
                    LoadFlashcardDecksEvent(
                      search: _searchQuery.isEmpty ? null : _searchQuery,
                    ),
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

                if (state is FlashcardDecksLoaded) {
                  if (state.decks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.style_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No decks yet'
                                : 'No decks found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Create your first deck to start learning'
                                : 'Try a different search term',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<FlashcardDeckBloc>().add(
                        LoadFlashcardDecksEvent(
                          search: _searchQuery.isEmpty ? null : _searchQuery,
                        ),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.decks.length + 1, // +1 for stats header
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Stats header
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.style,
                                    label: 'Total Decks',
                                    value: state.decks.length.toString(),
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.layers,
                                    label: 'Total Cards',
                                    value: state.decks
                                        .fold(
                                          0,
                                          (sum, deck) => sum + deck.totalCards,
                                        )
                                        .toString(),
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final deck = state.decks[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FlashcardDeckCard(
                            deck: deck,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DeckDetailPage(deckId: deck.id),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditDeckPage(deck: deck),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  // Reload list after editing
                                  context.read<FlashcardDeckBloc>().add(
                                    LoadFlashcardDecksEvent(
                                      search: _searchQuery.isEmpty
                                          ? null
                                          : _searchQuery,
                                    ),
                                  );
                                }
                              });
                            },
                            onDelete: () =>
                                _confirmDelete(context, deck.id, deck.name),
                          ),
                        );
                      },
                    ),
                  );
                }

                // Initial or error state
                return Center(
                  child: Text(
                    'Pull to refresh',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDeckPage()),
          );
          if (result == true && mounted) {
            // Reload list after creating
            context.read<FlashcardDeckBloc>().add(
              LoadFlashcardDecksEvent(
                search: _searchQuery.isEmpty ? null : _searchQuery,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Deck'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
}

/// Small stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
