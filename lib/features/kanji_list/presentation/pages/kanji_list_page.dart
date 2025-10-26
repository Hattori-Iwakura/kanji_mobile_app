import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';
import '../bloc/kanji_list_state.dart';
import '../widgets/kanji_list_card.dart';
import 'create_kanji_list_page.dart';
import 'kanji_list_detail_page.dart';
import 'edit_kanji_list_page.dart';

/// Page displaying list of all kanji lists
class KanjiListPage extends StatelessWidget {
  const KanjiListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<KanjiListBloc>()..add(const LoadKanjiListsEvent()),
      child: const _KanjiListView(),
    );
  }
}

class _KanjiListView extends StatefulWidget {
  const _KanjiListView();

  @override
  State<_KanjiListView> createState() => _KanjiListViewState();
}

class _KanjiListViewState extends State<_KanjiListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedJlpt; // Track selected JLPT level

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
          'Kanji Lists',
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
                hintText: 'Search lists...',
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
                          context.read<KanjiListBloc>().add(
                            const LoadKanjiListsEvent(),
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
                    context.read<KanjiListBloc>().add(
                      LoadKanjiListsEvent(search: value.isEmpty ? null : value),
                    );
                  }
                });
              },
            ),
          ),

          // JLPT Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "All" chip
                  _buildJlptChip(
                    label: 'All',
                    isSelected: _selectedJlpt == null,
                    onTap: () {
                      setState(() => _selectedJlpt = null);
                      context.read<KanjiListBloc>().add(
                        LoadKanjiListsEvent(
                          search: _searchQuery.isEmpty ? null : _searchQuery,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // JLPT N5-N1 chips
                  ...['N5', 'N4', 'N3', 'N2', 'N1'].map(
                    (level) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildJlptChip(
                        label: level,
                        isSelected: _selectedJlpt == level,
                        onTap: () {
                          setState(() => _selectedJlpt = level);
                          context.read<KanjiListBloc>().add(
                            FilterByJlptEvent(level),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kanji list
          Expanded(
            child: BlocConsumer<KanjiListBloc, KanjiListState>(
              listener: (context, state) {
                if (state is KanjiListDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('List deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload list
                  context.read<KanjiListBloc>().add(
                    LoadKanjiListsEvent(
                      search: _searchQuery.isEmpty ? null : _searchQuery,
                    ),
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

                if (state is KanjiListsLoaded) {
                  if (state.lists.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.list_alt_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No lists yet'
                                : 'No lists found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Create your first list to organize kanji'
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
                      context.read<KanjiListBloc>().add(
                        LoadKanjiListsEvent(
                          search: _searchQuery.isEmpty ? null : _searchQuery,
                        ),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.lists.length + 1, // +1 for stats header
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // Stats header
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.list_alt,
                                    label: 'Total Lists',
                                    value: state.lists.length.toString(),
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    icon: Icons.text_fields,
                                    label: 'Total Kanji',
                                    value: state.lists
                                        .fold(
                                          0,
                                          (sum, list) => sum + list.totalKanji,
                                        )
                                        .toString(),
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final kanjiList = state.lists[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: KanjiListCard(
                            kanjiList: kanjiList,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      KanjiListDetailPage(listId: kanjiList.id),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditKanjiListPage(kanjiList: kanjiList),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  // Reload list after editing
                                  context.read<KanjiListBloc>().add(
                                    LoadKanjiListsEvent(
                                      search: _searchQuery.isEmpty
                                          ? null
                                          : _searchQuery,
                                    ),
                                  );
                                }
                              });
                            },
                            onDelete: () => _confirmDelete(
                              context,
                              kanjiList.id,
                              kanjiList.name,
                            ),
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
            MaterialPageRoute(builder: (_) => const CreateKanjiListPage()),
          );
          if (result == true && mounted) {
            // Reload list after creating
            context.read<KanjiListBloc>().add(
              LoadKanjiListsEvent(
                search: _searchQuery.isEmpty ? null : _searchQuery,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New List'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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

  /// Build JLPT filter chip
  Widget _buildJlptChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
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
