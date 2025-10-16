import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/search_kanji.dart';
import '../bloc/search/kanji_search_bloc.dart';
import '../bloc/search/kanji_search_event.dart';
import '../bloc/search/kanji_search_state.dart';
import 'kanji_detail_page.dart';

class KanjiSearchPage extends StatelessWidget {
  const KanjiSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<KanjiSearchBloc>(),
      child: const KanjiSearchView(),
    );
  }
}

class KanjiSearchView extends StatefulWidget {
  const KanjiSearchView({super.key});

  @override
  State<KanjiSearchView> createState() => _KanjiSearchViewState();
}

class _KanjiSearchViewState extends State<KanjiSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<KanjiSearchBloc>().add(const LoadMoreResults());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<KanjiSearchBloc>().add(const ClearSearch());
    } else {
      final params = SearchKanjiParams(query: query, page: 1, limit: 20);
      context.read<KanjiSearchBloc>().add(SearchKanjiRequested(params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search kanji...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // Debounce would be better here
                if (value.length >= 1) {
                  _onSearch(value);
                }
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<KanjiSearchBloc, KanjiSearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return const Center(child: Text('Start searching for kanji'));
          }

          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is SearchLoaded || state is SearchLoadingMore) {
            final result = state is SearchLoaded
                ? state.result
                : (state as SearchLoadingMore).currentResult;
            final kanji = result.data;

            if (kanji.isEmpty) {
              return const Center(child: Text('No kanji found'));
            }

            return Column(
              children: [
                // Results info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Found ${result.meta.total} kanji (Page ${result.meta.page}/${result.meta.totalPages})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                // Results grid
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount:
                        kanji.length + (state is SearchLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= kanji.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final k = kanji[index];
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            // Navigate to detail page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    KanjiDetailPage(character: k.character),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                k.character,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (k.jlpt != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getJlptColor(k.jlpt!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'N${k.jlpt}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterDialog(context);
        },
        child: const Icon(Icons.filter_list),
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filters'),
        content: const Text('Filter options coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
