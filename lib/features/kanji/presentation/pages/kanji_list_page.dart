import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import '../bloc/kanji_list_bloc.dart';
import 'kanji_detail_page.dart';
import 'stats_page.dart';
import 'my_lists_page.dart';

class KanjiListPage extends StatefulWidget {
  const KanjiListPage({super.key});

  @override
  State<KanjiListPage> createState() => _KanjiListPageState();
}

class _KanjiListPageState extends State<KanjiListPage> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedGrade;

  @override
  void initState() {
    super.initState();
    context.read<KanjiBloc>().add(LoadAllKanjiEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<KanjiBloc>().add(LoadAllKanjiEvent());
    } else {
      context.read<KanjiBloc>().add(SearchKanjiEvent(query));
    }
  }

  void _onGradeFilter(int? grade) {
    setState(() {
      _selectedGrade = grade;
    });

    if (grade == null) {
      context.read<KanjiBloc>().add(LoadAllKanjiEvent());
    } else {
      context.read<KanjiBloc>().add(LoadKanjiByGradeEvent(grade));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học Kanji'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special),
            onPressed: () {
              final kanjiListBloc = context.read<KanjiListBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: kanjiListBloc,
                    child: const MyListsPage(),
                  ),
                ),
              );
            },
            tooltip: 'Danh sách Kanji',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsPage()),
              );
            },
            tooltip: 'Thống kê',
          ),
          PopupMenuButton<int?>(
            icon: const Icon(Icons.filter_list),
            onSelected: _onGradeFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Tất cả')),
              ...List.generate(6, (index) {
                final grade = index + 1;
                return PopupMenuItem(value: grade, child: Text('Lớp $grade'));
              }),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm kanji...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),
          if (_selectedGrade != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Chip(
                label: Text('Lớp $_selectedGrade'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _onGradeFilter(null),
              ),
            ),
          Expanded(
            child: BlocBuilder<KanjiBloc, KanjiState>(
              builder: (context, state) {
                if (state is KanjiLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is KanjiLoaded) {
                  if (state.kanjiList.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy kanji nào'),
                    );
                  }
                  return _buildKanjiGrid(state.kanjiList);
                } else if (state is KanjiError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<KanjiBloc>().add(LoadAllKanjiEvent());
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Bắt đầu tìm kiếm kanji'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanjiGrid(List<Kanji> kanjiList) {
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
        return _buildKanjiCard(kanji);
      },
    );
  }

  Widget _buildKanjiCard(Kanji kanji) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KanjiDetailPage(kanji: kanji),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.indigo.shade100, Colors.indigo.shade50],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kanji.character,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (kanji.grade != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'N${kanji.grade}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
