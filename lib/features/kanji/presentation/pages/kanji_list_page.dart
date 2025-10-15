import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';

class KanjiListPage extends StatefulWidget {
  const KanjiListPage({Key? key}) : super(key: key);

  @override
  State<KanjiListPage> createState() => _KanjiListPageState();
}

class _KanjiListPageState extends State<KanjiListPage> {
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
          title: const Text('Kanji List'),
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
            _buildFilterChips(),
            Expanded(child: _buildKanjiList()),
          ],
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

  Widget _buildFilterChips() {
    return BlocBuilder<KanjiBloc, KanjiState>(
      builder: (context, state) {
        if (state is! KanjiListLoaded) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (state.filterType != null)
                ActionChip(
                  label: const Text('Clear Filter'),
                  avatar: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
                  },
                ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final level = 5 - index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('N$level'),
                    selected: state.filterType == 'jlpt_$level',
                    onSelected: (selected) {
                      if (selected) {
                        context.read<KanjiBloc>().add(
                          FilterKanjiByJlptEvent(level),
                        );
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKanjiList() {
    return BlocBuilder<KanjiBloc, KanjiState>(
      builder: (context, state) {
        if (state is KanjiLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is KanjiError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is KanjiListLoaded) {
          final kanjiList = state.filteredList;

          if (kanjiList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
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
                      Row(
                        children: [
                          if (kanji.jlptLevel != null)
                            Chip(
                              label: Text(kanji.jlptLevel!),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          if (kanji.grade != null) ...[
                            const SizedBox(width: 4),
                            Chip(
                              label: Text('Grade ${kanji.grade}'),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/kanji-detail',
                      arguments: kanji.id,
                    );
                  },
                ),
              );
            },
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('JLPT Level'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(dialogContext);
                _showJlptFilter(context);
              },
            ),
            ListTile(
              title: const Text('Grade'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(dialogContext);
                _showGradeFilter(context);
              },
            ),
            ListTile(
              title: const Text('Clear All Filters'),
              leading: const Icon(Icons.clear),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showJlptFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter by JLPT Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final level = 5 - index;
            return ListTile(
              title: Text('N$level'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<KanjiBloc>().add(FilterKanjiByJlptEvent(level));
              },
            );
          }),
        ),
      ),
    );
  }

  void _showGradeFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter by Grade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(6, (index) {
            final grade = index + 1;
            return ListTile(
              title: Text('Grade $grade'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<KanjiBloc>().add(FilterKanjiByGradeEvent(grade));
              },
            );
          }),
        ),
      ),
    );
  }
}
