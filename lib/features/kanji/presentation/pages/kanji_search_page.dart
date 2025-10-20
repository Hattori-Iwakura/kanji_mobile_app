import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import '../../../../core/routes/app_routes.dart';

class KanjiSearchPage extends StatefulWidget {
  const KanjiSearchPage({Key? key}) : super(key: key);

  @override
  State<KanjiSearchPage> createState() => _KanjiSearchPageState();
}

class _KanjiSearchPageState extends State<KanjiSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<KanjiBloc>().add(LoadKanjiListEvent(search: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<KanjiBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            decoration: const InputDecoration(
              hintText: 'Search kanji...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            autofocus: true,
            onSubmitted: (_) => _performSearch(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _performSearch(context),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<KanjiBloc>().add(LoadKanjiListEvent());
              },
            ),
          ],
        ),
        body: BlocBuilder<KanjiBloc, KanjiState>(
          builder: (context, state) {
            if (state is KanjiLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KanjiError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                  ],
                ),
              );
            }

            if (state is KanjiListLoaded) {
              if (state.kanjiList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No kanji found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.kanjiList.length,
                itemBuilder: (context, index) {
                  final kanji = state.kanjiList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            kanji.character,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        kanji.meanings.isNotEmpty
                            ? kanji.meanings.join(', ')
                            : 'No meaning',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (kanji.onyomi != null || kanji.kunyomi != null)
                            Text(
                              [
                                if (kanji.onyomi != null) 'On: ${kanji.onyomi}',
                                if (kanji.kunyomi != null) 'Kun: ${kanji.kunyomi}',
                              ].join(' • '),
                            ),
                          Row(
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
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                '${kanji.strokeCount} strokes',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.kanjiDetail,
                          arguments: kanji.id,
                        );
                      },
                    ),
                  );
                },
              );
            }

            // Initial state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Search for kanji',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter a character, meaning, or reading',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
