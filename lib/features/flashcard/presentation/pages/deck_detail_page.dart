import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/flashcard_card.dart';
import '../../domain/entities/flashcard_deck.dart';
import '../bloc/deck_detail_bloc.dart';
import '../bloc/deck_detail_event.dart';
import '../bloc/deck_detail_state.dart';
import '../../../../injection_container.dart' as di;
import 'study_session_page.dart';
import 'card_detail_page.dart';
import 'deck_edit_page.dart';
import 'flashcard_stats_page.dart';

class DeckDetailPage extends StatelessWidget {
  final int deckId;

  const DeckDetailPage({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DeckDetailBloc>()..add(LoadDeckDetailEvent(deckId)),
      child: _DeckDetailView(deckId: deckId),
    );
  }
}

class _DeckDetailView extends StatefulWidget {
  final int deckId;

  const _DeckDetailView({required this.deckId});

  @override
  State<_DeckDetailView> createState() => _DeckDetailViewState();
}

class _DeckDetailViewState extends State<_DeckDetailView> {
  FlashcardDeck? _deck;
  List<FlashcardCard> _cards = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_deck?.name ?? 'Deck Detail'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'View stats',
            onPressed: _deck == null
                ? null
                : () => _openStatsPage(context, widget.deckId, _deck!.name),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit deck',
            onPressed: _deck == null
                ? null
                : () => _openEditDeck(context, _deck!),
          ),
          IconButton(
            icon: const Icon(Icons.library_add_outlined),
            tooltip: 'Bulk add cards',
            onPressed: _deck == null ? null : () => _showBulkAddDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add card',
            onPressed: _deck == null ? null : () => _showAddCardDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<DeckDetailBloc, DeckDetailState>(
        listener: (context, state) {
          if (state is DeckDetailLoaded) {
            setState(() {
              _deck = state.deck;
              final cards = state.deck.cards ?? [];
              _cards = List.of(cards)
                ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
            });
          } else if (state is DeckDetailError && _deck != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is DeckDetailLoading && _deck == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (state is DeckDetailError && _deck == null) {
            return _buildInitialError(context, state.message);
          }

          final deck = _deck;
          if (deck == null) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              _buildDeckContent(context, deck),
              if (state is DeckDetailLoading && _deck != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeckContent(BuildContext context, FlashcardDeck deck) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DeckInfoHeader(
          deck: deck,
          onStudy: deck.totalCards > 0
              ? () => _startStudy(context, widget.deckId)
              : null,
        ),
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
                '(${_cards.length})',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _cards.isEmpty
              ? const _EmptyCardsPlaceholder()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cards.length,
                  buildDefaultDragHandles: false,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _CardListTile(
                      key: ValueKey(card.id),
                      card: card,
                      index: index,
                      onViewDetail: () => _openCardDetail(context, card),
                      onDelete: () => _showDeleteCardDialog(context, card.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInitialError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<DeckDetailBloc>().add(
              LoadDeckDetailEvent(widget.deckId),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final card = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, card);
    });

    context.read<DeckDetailBloc>().add(
      ReorderCardsEvent(
        deckId: widget.deckId,
        orderedCardIds: _cards.map((card) => card.id).toList(),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Add Card', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
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
              final kanjiId = int.tryParse(controller.text.trim());
              if (kanjiId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid kanji ID'),
                  ),
                );
                return;
              }
              context.read<DeckDetailBloc>().add(
                AddCardToDeckEvent(deckId: widget.deckId, kanjiId: kanjiId),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showBulkAddDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text(
          'Bulk Add Cards',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter kanji IDs separated by comma or newline',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '101, 202, 303',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text.trim();
              final ids = input
                  .split(RegExp(r'[\\s,]+'))
                  .map(int.tryParse)
                  .whereType<int>()
                  .toList();

              if (ids.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide at least one ID'),
                  ),
                );
                return;
              }

              context.read<DeckDetailBloc>().add(
                BulkAddCardsEvent(deckId: widget.deckId, kanjiIds: ids),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCardDialog(BuildContext context, int cardId) {
    showDialog<void>(
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<DeckDetailBloc>().add(DeleteCardEvent(cardId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _startStudy(BuildContext context, int deckId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudySessionPage(deckId: deckId)),
    );
  }

  void _openCardDetail(BuildContext context, FlashcardCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CardDetailPage(cardId: card.id, kanjiCharacter: card.frontContent),
      ),
    );
  }

  void _openEditDeck(BuildContext context, FlashcardDeck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DeckDetailBloc>(),
          child: DeckEditPage(deck: deck),
        ),
      ),
    );
  }

  void _openStatsPage(BuildContext context, int deckId, String deckName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardStatsPage(deckId: deckId, deckName: deckName),
      ),
    );
  }
}

class _DeckInfoHeader extends StatelessWidget {
  final FlashcardDeck deck;
  final VoidCallback? onStudy;

  const _DeckInfoHeader({required this.deck, this.onStudy});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (deck.description != null && deck.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              deck.description!,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.style,
                label: '${deck.totalCards} cards',
                color: Colors.blue,
              ),
              if (deck.cardsNew > 0)
                _StatChip(
                  icon: Icons.fiber_new,
                  label: '${deck.cardsNew} new',
                  color: Colors.green,
                ),
              if (deck.cardsDue > 0)
                _StatChip(
                  icon: Icons.schedule,
                  label: '${deck.cardsDue} due',
                  color: Colors.orange,
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStudy,
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
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _EmptyCardsPlaceholder extends StatelessWidget {
  const _EmptyCardsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No cards yet',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the + button to add cards',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CardListTile extends StatelessWidget {
  final FlashcardCard card;
  final int index;
  final VoidCallback onViewDetail;
  final VoidCallback onDelete;

  const _CardListTile({
    super.key,
    required this.card,
    required this.index,
    required this.onViewDetail,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final backContent = card.backContent;
    final meanings = backContent['meanings'] is List
        ? (backContent['meanings'] as List).join(', ')
        : backContent['meanings']?.toString();

    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ReorderableDragStartListener(
          index: index,
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.2),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ),
        title: Text(
          card.frontContent,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meanings != null && meanings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  meanings,
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (card.isNew)
                  const _InfoPill(label: 'New', color: Colors.green),
                _InfoPill(
                  label: 'Ease ${(card.easeFactor).toStringAsFixed(2)}',
                  color: Colors.blueGrey,
                ),
                _InfoPill(
                  label: 'Interval ${card.intervalDays}d',
                  color: Colors.orangeAccent,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.insights_outlined,
                color: Colors.lightBlue,
              ),
              tooltip: 'Card detail',
              onPressed: onViewDetail,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete card',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
