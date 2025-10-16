import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/lists/kanji_lists_bloc.dart';
import '../bloc/lists/kanji_lists_event.dart';
import '../bloc/lists/kanji_lists_state.dart';
import 'kanji_list_detail_page.dart';

class KanjiListsPage extends StatelessWidget {
  const KanjiListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KanjiListsBloc>()..add(const LoadUserLists()),
      child: const KanjiListsView(),
    );
  }
}

class KanjiListsView extends StatelessWidget {
  const KanjiListsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Kanji Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanjiListsBloc>().add(const LoadUserLists());
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
            // Reload lists after operation
            context.read<KanjiListsBloc>().add(const LoadUserLists());
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
                      context.read<KanjiListsBloc>().add(const LoadUserLists());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ListsLoaded) {
            final lists = state.lists;

            if (lists.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiListsBloc>().add(const LoadUserLists());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return _buildListCard(context, list);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateListDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create List'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 120, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'No Lists Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first kanji list to get started',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateListDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create List'),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, list) {
    return Dismissible(
      key: Key(list.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete List'),
            content: Text('Are you sure you want to delete "${list.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<KanjiListsBloc>().add(DeleteListEvent(list.id.toString()));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => KanjiListDetailPage(
                  listId: list.id.toString(),
                  listName: list.name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        list.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${list.itemCount} kanji',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (list.description != null &&
                    list.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    list.description!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (list.previewItems.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Preview: ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          children: list.previewItems.map<Widget>((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.kanji.character,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      list.isPublic ? Icons.public : Icons.lock,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      list.isPublic ? 'Public' : 'Private',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Created ${_formatDate(list.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showCreateListDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New List'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'List Name',
                    hintText: 'e.g., JLPT N5 Kanji',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Describe your list...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Make Public'),
                  subtitle: const Text('Others can see this list'),
                  value: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a list name')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                context.read<KanjiListsBloc>().add(
                  CreateList(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim().isEmpty
                        ? null
                        : descriptionController.text.trim(),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
