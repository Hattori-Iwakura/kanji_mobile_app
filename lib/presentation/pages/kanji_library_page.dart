import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanji_flutter/domain/entities/kanji_entity.dart';
import 'package:kanji_flutter/domain/repositories/kanji_repository.dart';
import 'package:kanji_flutter/data/repositories/kanji_repository_hybrid.dart';
import '../blocs/kanji_bloc.dart';
import '../widgets/kanji_card.dart';
import '../widgets/kanji_search_bar.dart';
import '../widgets/kanji_detail_dialog.dart';
import '../widgets/sync_status_widget.dart';

class KanjiLibraryPage extends StatelessWidget {
  final KanjiRepository repo;

  const KanjiLibraryPage({Key? key, required this.repo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KanjiBloc(repo)..add(LoadKanjis()),
      child: KanjiLibraryView(repo: repo),
    );
  }
}

class KanjiLibraryView extends StatefulWidget {
  final KanjiRepository repo;

  const KanjiLibraryView({Key? key, required this.repo}) : super(key: key);

  @override
  State<KanjiLibraryView> createState() => _KanjiLibraryViewState();
}

class _KanjiLibraryViewState extends State<KanjiLibraryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showKanjiDetail(Kanji kanji) {
    showDialog(
      context: context,
      builder: (context) => KanjiDetailDialog(kanji: kanji),
    );
  }

  void _showAddKanjiDialog() {
    showDialog(
      context: context,
      builder: (context) => KanjiDetailDialog(
        onSave: (kanjiData) {
          context.read<KanjiBloc>().add(
            AddKanjiEvent(
              Kanji(
                id: 0, // Server sẽ tạo ID
                character: kanjiData['character'] ?? '',
                meanings: kanjiData['meanings'] ?? '',
                onyomi: kanjiData['onyomi'],
                kunyomi: kanjiData['kunyomi'],
                strokeCount: kanjiData['strokeCount'],
                jlpt: kanjiData['jlpt'],
                grade: kanjiData['grade'],
                frequency: kanjiData['frequency'],
                radicals: kanjiData['radicals'],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Library'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (widget.repo is KanjiRepositoryHybrid)
            IconButton(
              onPressed: () => _showSyncDialog(context),
              icon: const Icon(Icons.sync),
              tooltip: 'Sync Status',
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: KanjiSearchBar(
              controller: _searchController,
              onSearch: (query) {
                context.read<KanjiBloc>().add(SearchKanjiEvent(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.kanjis.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No kanji found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or add new kanji',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.kanjis.length,
                  itemBuilder: (context, index) {
                    final kanji = state.kanjis[index];
                    return KanjiCard(
                      kanji: kanji,
                      onTap: () => _showKanjiDetail(kanji),
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (context) => KanjiDetailDialog(
                            kanji: kanji,
                            onSave: (kanjiData) {
                              context.read<KanjiBloc>().add(
                                UpdateKanjiEvent(
                                  kanji.id,
                                  Kanji(
                                    id: kanji.id,
                                    character:
                                        kanjiData['character'] ??
                                        kanji.character,
                                    meanings:
                                        kanjiData['meanings'] ?? kanji.meanings,
                                    onyomi: kanjiData['onyomi'] ?? kanji.onyomi,
                                    kunyomi:
                                        kanjiData['kunyomi'] ?? kanji.kunyomi,
                                    strokeCount:
                                        kanjiData['strokeCount'] ??
                                        kanji.strokeCount,
                                    jlpt: kanjiData['jlpt'] ?? kanji.jlpt,
                                    grade: kanjiData['grade'] ?? kanji.grade,
                                    frequency:
                                        kanjiData['frequency'] ??
                                        kanji.frequency,
                                    radicals:
                                        kanjiData['radicals'] ?? kanji.radicals,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Kanji'),
                            content: Text(
                              'Are you sure you want to delete "${kanji.character}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<KanjiBloc>().add(
                                    DeleteKanjiEvent(kanji.id),
                                  );
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddKanjiDialog,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    if (widget.repo is KanjiRepositoryHybrid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sync Status'),
          content: SizedBox(
            width: double.maxFinite,
            child: SyncStatusWidget(
              repository: widget.repo as KanjiRepositoryHybrid,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
