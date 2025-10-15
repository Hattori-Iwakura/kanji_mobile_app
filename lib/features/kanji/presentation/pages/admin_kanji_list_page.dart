import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import 'kanji_form_page.dart';

class AdminKanjiListPage extends StatefulWidget {
  const AdminKanjiListPage({Key? key}) : super(key: key);

  @override
  State<AdminKanjiListPage> createState() => _AdminKanjiListPageState();
}

class _AdminKanjiListPageState extends State<AdminKanjiListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<KanjiBloc>()..add(const LoadAllKanjiEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin - Kanji Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildKanjiList()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToCreateKanji(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Kanji'),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by character, meaning, reading...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<KanjiBloc>().add(const SearchKanjiEvent(''));
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          context.read<KanjiBloc>().add(SearchKanjiEvent(value));
          setState(() {});
        },
      ),
    );
  }

  Widget _buildKanjiList() {
    return BlocConsumer<KanjiBloc, KanjiState>(
      listener: (context, state) {
        if (state is KanjiListLoaded && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is KanjiOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is KanjiError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is KanjiLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is KanjiError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is KanjiListLoaded) {
          final kanjiList =
              state.filteredList.isEmpty && state.filterType == null
              ? state.kanjiList
              : state.filteredList;

          if (kanjiList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No kanji found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: kanjiList.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final kanji = kanjiList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      kanji.character,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    kanji.meaningsList.first,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (kanji.onyomi != null)
                        Text(
                          '音: ${kanji.onyomi}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (kanji.kunyomi != null)
                        Text(
                          '訓: ${kanji.kunyomi}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (kanji.jlptLevel != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                kanji.jlptLevel!,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (kanji.grade != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Grade ${kanji.grade}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToEditKanji(context, kanji),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, kanji),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Future<void> _navigateToCreateKanji(BuildContext context) async {
    final bloc = context.read<KanjiBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const KanjiFormPage()),
      ),
    );
    // No need to refresh - BLoC handles optimistic update
  }

  Future<void> _navigateToEditKanji(BuildContext context, Kanji kanji) async {
    final bloc = context.read<KanjiBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: KanjiFormPage(kanji: kanji),
        ),
      ),
    );
    // No need to refresh - BLoC handles optimistic update
  }

  Future<void> _confirmDelete(BuildContext context, Kanji kanji) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Kanji'),
        content: Text('Are you sure you want to delete "${kanji.character}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<KanjiBloc>().add(DeleteKanjiEvent(kanji.id));
    }
  }

  void _showFilterDialog(BuildContext context) {
    final bloc = context.read<KanjiBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Kanji'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JLPT Level:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: List.generate(5, (index) {
                final level = index + 1;
                return FilterChip(
                  label: Text('N$level'),
                  onSelected: (selected) {
                    bloc.add(FilterKanjiByJlptEvent(level));
                    Navigator.pop(ctx);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Grade:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: List.generate(6, (index) {
                final grade = index + 1;
                return FilterChip(
                  label: Text('Grade $grade'),
                  onSelected: (selected) {
                    bloc.add(FilterKanjiByGradeEvent(grade));
                    Navigator.pop(ctx);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                bloc.add(const LoadAllKanjiEvent());
                Navigator.pop(ctx);
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
