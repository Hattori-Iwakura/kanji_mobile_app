import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/lists/kanji_lists_bloc.dart';
import '../bloc/lists/kanji_lists_event.dart';
import '../bloc/lists/kanji_lists_state.dart';
import 'kanji_detail_page.dart';

class KanjiListDetailPage extends StatelessWidget {
  final String listId;
  final String listName;

  const KanjiListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KanjiListsBloc>()..add(LoadListDetail(listId)),
      child: KanjiListDetailView(listId: listId, listName: listName),
    );
  }
}

class KanjiListDetailView extends StatefulWidget {
  final String listId;
  final String listName;

  const KanjiListDetailView({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<KanjiListDetailView> createState() => _KanjiListDetailViewState();
}

class _KanjiListDetailViewState extends State<KanjiListDetailView> {
  bool _isReorderMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        actions: [
          if (!_isReorderMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddKanjiDialog(context),
            ),
          IconButton(
            icon: Icon(_isReorderMode ? Icons.done : Icons.reorder),
            onPressed: () {
              setState(() {
                _isReorderMode = !_isReorderMode;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete List', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteListDialog(context);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<KanjiListsBloc, KanjiListsState>(
        listener: (context, state) {
          if (state is ListOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // Reload list detail
            context.read<KanjiListsBloc>().add(LoadListDetail(widget.listId));
          } else if (state is ListsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ListsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<KanjiListsBloc>().add(
                        LoadListDetail(widget.listId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ListDetailLoaded) {
            final list = state.list;
            final items = list.items ?? [];

            if (items.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiListsBloc>().add(
                  LoadListDetail(widget.listId),
                );
              },
              child: _isReorderMode
                  ? _buildReorderableGrid(context, items)
                  : _buildNormalGrid(context, items),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view, size: 120, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'No Kanji in This List',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add kanji to start building your list',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddKanjiDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Kanji'),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalGrid(BuildContext context, List items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildKanjiCard(context, item);
      },
    );
  }

  Widget _buildReorderableGrid(BuildContext context, List items) {
    // For reorderable, we'll use a simple approach with long press
    // A better solution would be using ReorderableGridView package
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildKanjiCard(context, item, showReorderIcon: true);
      },
    );
  }

  Widget _buildKanjiCard(
    BuildContext context,
    item, {
    bool showReorderIcon = false,
  }) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Remove Kanji'),
            content: Text('Remove "${item.kanji.character}" from this list?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<KanjiListsBloc>().add(
          RemoveKanjiFromListEvent(
            listId: widget.listId,
            kanjiId: item.kanjiId.toString(),
          ),
        );
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            if (!_isReorderMode) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      KanjiDetailPage(character: item.kanji.character),
                ),
              );
            }
          },
          onLongPress: item.notes != null && item.notes!.isNotEmpty
              ? () => _showNotesDialog(context, item)
              : null,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.kanji.character,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.kanji.jlpt != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getJlptColor(item.kanji.jlpt!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'N${item.kanji.jlpt}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.notes != null && item.notes!.isNotEmpty)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(Icons.note, size: 16, color: Colors.grey),
                ),
              if (showReorderIcon)
                const Positioned(
                  top: 4,
                  left: 4,
                  child: Icon(Icons.drag_handle, size: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getJlptColor(int jlpt) {
    switch (jlpt) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddKanjiDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Kanji'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Enter kanji characters',
                hintText: 'e.g., 日本語',
                border: OutlineInputBorder(),
                helperText:
                    'Separate multiple kanji with spaces or just paste them',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: You can paste multiple kanji at once',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = searchController.text.trim();
              if (input.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter kanji characters'),
                  ),
                );
                return;
              }

              // Extract individual kanji characters (remove spaces and duplicates)
              final characters = input
                  .replaceAll(' ', '')
                  .split('')
                  .where((char) => char.trim().isNotEmpty)
                  .toSet()
                  .toList();

              Navigator.pop(dialogContext);
              context.read<KanjiListsBloc>().add(
                AddKanjiToListEvent(
                  listId: widget.listId,
                  characters: characters,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Notes for ${item.kanji.character}'),
        content: Text(item.notes ?? 'No notes'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete List'),
        content: Text(
          'Are you sure you want to delete "${widget.listName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<KanjiListsBloc>().add(
                DeleteListEvent(widget.listId),
              );
              // Go back to lists page
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
