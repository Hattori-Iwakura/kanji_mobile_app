import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';
import '../bloc/kanji_list_state.dart';

class KanjiListDetailPage extends StatelessWidget {
  final int listId;

  const KanjiListDetailPage({Key? key, required this.listId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<KanjiListBloc>()..add(LoadListByIdEvent(listId)),
      child: _KanjiListDetailView(listId: listId),
    );
  }
}

class _KanjiListDetailView extends StatelessWidget {
  final int listId;

  const _KanjiListDetailView({required this.listId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanjiListBloc>().add(LoadListByIdEvent(listId));
            },
          ),
        ],
      ),
      body: BlocConsumer<KanjiListBloc, KanjiListState>(
        listener: (context, state) {
          if (state is KanjiListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is KanjiAddedToList || state is KanjiRemovedFromList) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is KanjiAddedToList
                      ? 'Kanji added successfully'
                      : 'Kanji removed successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.read<KanjiListBloc>().add(LoadListByIdEvent(listId));
          }
        },
        builder: (context, state) {
          if (state is KanjiListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListDetailLoaded) {
            final list = state.list;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiListBloc>().add(LoadListByIdEvent(listId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // List Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (list.description != null && list.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              list.description!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStatChip(
                                icon: Icons.style,
                                label: '${list.totalKanji} kanji',
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                icon: list.isPublic ? Icons.public : Icons.lock,
                                label: list.isPublic ? 'Public' : 'Private',
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Kanji Items Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kanji Items (${list.totalKanji})',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddKanjiDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                    ),

                    // Note: ListDetailLoaded doesn't include kanji items
                    // Would need separate usecase or modify state to include items
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Kanji items list coming soon...\nUse Add Kanji feature to add items',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddKanjiDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Kanji'),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddKanjiDialog(BuildContext context) {
    final kanjiIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Kanji to List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kanjiIdController,
              decoration: const InputDecoration(
                labelText: 'Kanji ID',
                hintText: 'Enter kanji ID',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the ID of the kanji you want to add to this list',
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
              final kanjiIdText = kanjiIdController.text.trim();
              if (kanjiIdText.isNotEmpty) {
                final kanjiId = int.tryParse(kanjiIdText);
                if (kanjiId != null) {
                  context.read<KanjiListBloc>().add(
                        AddKanjiToListEvent(
                          listId: listId,
                          kanjiId: kanjiId,
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
