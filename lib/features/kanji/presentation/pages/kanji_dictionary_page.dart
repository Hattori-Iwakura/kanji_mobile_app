import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';

class KanjiDictionaryPage extends StatelessWidget {
  const KanjiDictionaryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<KanjiBloc>()..add(LoadKanjiListEvent(limit: 100)),
      child: const _KanjiDictionaryView(),
    );
  }
}

class _KanjiDictionaryView extends StatelessWidget {
  const _KanjiDictionaryView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        authState is Authenticated && authState.user.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanji Dictionary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanjiBloc>().add(LoadKanjiListEvent());
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.kanjiCreate);
              },
            ),
        ],
      ),
      body: BlocConsumer<KanjiBloc, KanjiState>(
        listener: (context, state) {
          if (state is KanjiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is KanjiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is KanjiListLoaded) {
            if (state.kanjiList.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<KanjiBloc>().add(LoadKanjiListEvent());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: state.kanjiList.length,
                itemBuilder: (context, index) {
                  final kanji = state.kanjiList[index];
                  return _buildKanjiCard(context, kanji);
                },
              ),
            );
          }

          return _buildEmptyState(context);
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

  Widget _buildKanjiCard(BuildContext context, kanji) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.kanjiDetail,
            arguments: kanji.id,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kanji.character,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (kanji.meanings.isNotEmpty)
              Text(
                kanji.meanings.first,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (kanji.jlptLevel != null) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kanji.jlptLevel!,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No kanji found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<KanjiBloc>().add(LoadKanjiListEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Load Kanji'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? selectedJlpt;
    int? selectedGrade;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Kanji'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'JLPT Level'),
                value: selectedJlpt,
                items: ['N5', 'N4', 'N3', 'N2', 'N1']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedJlpt = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Grade'),
                value: selectedGrade,
                items: List.generate(6, (i) => i + 1)
                    .map(
                      (grade) => DropdownMenuItem(
                        value: grade,
                        child: Text('Grade $grade'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedGrade = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<KanjiBloc>().add(LoadKanjiListEvent());
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<KanjiBloc>().add(
                LoadKanjiListEvent(
                  jlptLevel: selectedJlpt,
                  grade: selectedGrade,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
