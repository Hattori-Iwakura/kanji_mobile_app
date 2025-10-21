import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';
import '../bloc/kanji_list_state.dart';
import '../widgets/create_edit_list_dialog.dart';

class KanjiListsPage extends StatelessWidget {
  const KanjiListsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<KanjiListBloc>()..add(LoadAllListsEvent()),
      child: const _KanjiListsView(),
    );
  }
}

class _KanjiListsView extends StatelessWidget {
  const _KanjiListsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanjiListBloc>().add(LoadAllListsEvent());
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
          } else if (state is ListCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('List created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<KanjiListBloc>().add(LoadAllListsEvent());
          } else if (state is ListDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('List deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<KanjiListBloc>().add(LoadAllListsEvent());
          }
        },
        builder: (context, state) {
          if (state is KanjiListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListsLoaded) {
            if (state.lists.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiListBloc>().add(LoadAllListsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.lists.length,
                itemBuilder: (context, index) {
                  final list = state.lists[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${list.totalKanji}')),
                      title: Text(
                        list.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (list.description != null &&
                              list.description!.isNotEmpty)
                            Text(
                              list.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                list.isPublic ? Icons.public : Icons.lock,
                                size: 14,
                                color: list.isPublic
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                list.isPublic ? 'Public' : 'Private',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: list.isPublic
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              if (list.category != null) ...[
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    list.category!.name,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.blue[100],
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(context, list.id);
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.kanjiListDetail,
                          arguments: list.id,
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateListDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No kanji lists yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first list to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
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

  void _showCreateListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const CreateEditListDialog(),
    );
  }

  void _showDeleteDialog(BuildContext context, int listId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete List'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<KanjiListBloc>().add(DeleteListEvent(listId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
