import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';
import '../bloc/kanji_list_state.dart';
import '../widgets/kanji_list_item_widget.dart';
import 'edit_kanji_list_page.dart';

/// Page displaying details of a single kanji list
class KanjiListDetailPage extends StatelessWidget {
  final int listId;

  const KanjiListDetailPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<KanjiListBloc>()..add(LoadKanjiListByIdEvent(listId)),
      child: const _KanjiListDetailView(),
    );
  }
}

class _KanjiListDetailView extends StatelessWidget {
  const _KanjiListDetailView();

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
          'List Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<KanjiListBloc, KanjiListState>(
            builder: (context, state) {
              if (state is KanjiListLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditKanjiListPage(kanjiList: state.list),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          // Reload list details
                          context.read<KanjiListBloc>().add(
                            LoadKanjiListByIdEvent(state.list.id),
                          );
                        }
                      });
                    } else if (value == 'delete') {
                      _confirmDelete(context, state.list.id, state.list.name);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit List'),
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
                            'Delete List',
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
      body: BlocConsumer<KanjiListBloc, KanjiListState>(
        listener: (context, state) {
          if (state is KanjiListDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('List deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is KanjiRemovedFromList) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kanji removed from list'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload list
            context.read<KanjiListBloc>().add(
              LoadKanjiListByIdEvent(state.list.id),
            );
          } else if (state is KanjiListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is KanjiListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is KanjiListLoaded) {
            final kanjiList = state.list;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiListBloc>().add(
                  LoadKanjiListByIdEvent(kanjiList.id),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // List header
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
                                Icons.list_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  kanjiList.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (kanjiList.description != null &&
                              kanjiList.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              kanjiList.description!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Stats row
                          Row(
                            children: [
                              _StatChip(
                                icon: Icons.text_fields,
                                label: '${kanjiList.totalKanji} Kanji',
                              ),
                              const SizedBox(width: 12),
                              _StatChip(
                                icon: kanjiList.isPublic
                                    ? Icons.public
                                    : Icons.lock,
                                label: kanjiList.isPublic
                                    ? 'Public'
                                    : 'Private',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                kanjiList.userName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Kanji items header
                    Row(
                      children: [
                        Text(
                          'Kanji in this list',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${kanjiList.items.length} items',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Kanji list
                    if (kanjiList.items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.text_fields_outlined,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No kanji in this list yet',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
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
                        itemCount: kanjiList.items.length,
                        itemBuilder: (context, index) {
                          final item = kanjiList.items[index];
                          return KanjiListItemWidget(
                            item: item,
                            onTap: () {
                              // Navigate to kanji detail page (placeholder)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'View details for ${item.kanji.character}',
                                  ),
                                ),
                              );
                            },
                            onRemove: () {
                              _confirmRemoveKanji(
                                context,
                                kanjiList.id,
                                item.kanjiId,
                                item.kanji.character,
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          // Error or initial state
          return Center(
            child: Text(
              'Failed to load list details',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<KanjiListBloc, KanjiListState>(
        builder: (context, state) {
          if (state is KanjiListLoaded) {
            return FloatingActionButton.extended(
              onPressed: () {
                // Placeholder for practice mode
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Practice mode coming soon!')),
                );
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

  void _confirmDelete(BuildContext context, int listId, String listName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
          'Are you sure you want to delete "$listName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<KanjiListBloc>().add(DeleteKanjiListEvent(listId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveKanji(
    BuildContext context,
    int listId,
    int kanjiId,
    String kanjiChar,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Kanji?'),
        content: Text('Remove "$kanjiChar" from this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<KanjiListBloc>().add(
                RemoveKanjiFromListEvent(listId: listId, kanjiId: kanjiId),
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

/// Stat chip widget for list header
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
