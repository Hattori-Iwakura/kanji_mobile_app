import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import '../widgets/kanji_grid_item.dart';
import 'kanji_detail_page.dart';

/// Page displaying list of kanji in a grid
class KanjiListPage extends StatelessWidget {
  const KanjiListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<KanjiBloc>()..add(const LoadAllKanjiEvent(limit: 50)),
      child: const _KanjiListView(),
    );
  }
}

class _KanjiListView extends StatelessWidget {
  const _KanjiListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Kanji Dictionary',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to search page
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<KanjiBloc, KanjiState>(
        builder: (context, state) {
          if (state is KanjiLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is KanjiError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<KanjiBloc>().add(
                        const LoadAllKanjiEvent(limit: 50),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is KanjiListLoaded) {
            final kanjiList = state.kanjiList;

            if (kanjiList.isEmpty) {
              return const Center(
                child: Text(
                  'No kanji found',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: kanjiList.length,
              itemBuilder: (context, index) {
                final kanji = kanjiList[index];
                return KanjiGridItem(
                  kanji: kanji,
                  onTap: () => _navigateToDetail(context, kanji),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Kanji kanji) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)),
    );
  }

  void _showFilterDialog(BuildContext context) {
    int? selectedJlpt;
    int? selectedGrade;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Filter Kanji',
            style: TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JLPT Level:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [1, 2, 3, 4, 5].map((level) {
                      return ChoiceChip(
                        label: Text('N$level'),
                        selected: selectedJlpt == level,
                        onSelected: (selected) {
                          setState(() {
                            selectedJlpt = selected ? level : null;
                          });
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(
                          color: selectedJlpt == level
                              ? Colors.black
                              : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Grade:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [1, 2, 3, 4, 5, 6].map((grade) {
                      return ChoiceChip(
                        label: Text('$grade'),
                        selected: selectedGrade == grade,
                        onSelected: (selected) {
                          setState(() {
                            selectedGrade = selected ? grade : null;
                          });
                        },
                        selectedColor: Colors.white,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(
                          color: selectedGrade == grade
                              ? Colors.black
                              : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<KanjiBloc>().add(
                  const LoadAllKanjiEvent(limit: 50),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<KanjiBloc>().add(
                  LoadAllKanjiEvent(
                    jlpt: selectedJlpt,
                    grade: selectedGrade,
                    limit: 50,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
