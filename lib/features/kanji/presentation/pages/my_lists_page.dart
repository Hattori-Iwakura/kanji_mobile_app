import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/kanji_list.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/kanji_list_event.dart';
import '../bloc/kanji_list_state.dart';

class MyListsPage extends StatefulWidget {
  const MyListsPage({super.key});

  @override
  State<MyListsPage> createState() => _MyListsPageState();
}

class _MyListsPageState extends State<MyListsPage> {
  @override
  void initState() {
    super.initState();
    // Load lists when page opens
    context.read<KanjiListBloc>().add(LoadAllListsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Kanji'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<KanjiListBloc, KanjiListState>(
        builder: (context, state) {
          if (state is KanjiListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KanjiListsLoaded) {
            return _buildListView(context, state.lists);
          } else if (state is KanjiListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<KanjiListBloc>().add(LoadAllListsEvent());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Đang tải danh sách...'));
        },
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<KanjiList> lists) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lists.length,
      itemBuilder: (context, index) {
        final list = lists[index];
        return _buildListCard(context, list);
      },
    );
  }

  Widget _buildListCard(BuildContext context, KanjiList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to list detail page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chi tiết danh sách - Coming soon')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getFilterColor(
                        list.filterType,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFilterIcon(list.filterType),
                      color: _getFilterColor(list.filterType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (list.description != null)
                          Text(
                            list.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.description,
                    _getFilterTypeLabel(list),
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.library_books,
                    '${list.kanjiCount} kanji',
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFilterIcon(ListFilterType type) {
    switch (type) {
      case ListFilterType.jlptLevel:
        return Icons.school;
      case ListFilterType.frequency:
        return Icons.trending_up;
      case ListFilterType.grade:
        return Icons.grade;
      case ListFilterType.custom:
        return Icons.edit;
    }
  }

  Color _getFilterColor(ListFilterType type) {
    switch (type) {
      case ListFilterType.jlptLevel:
        return Colors.purple;
      case ListFilterType.frequency:
        return Colors.orange;
      case ListFilterType.grade:
        return Colors.blue;
      case ListFilterType.custom:
        return Colors.green;
    }
  }

  String _getFilterTypeLabel(KanjiList list) {
    switch (list.filterType) {
      case ListFilterType.jlptLevel:
        return 'JLPT N${list.filterValue}';
      case ListFilterType.frequency:
        return 'Độ phổ biến ${list.frequencyMin}-${list.frequencyMax}';
      case ListFilterType.grade:
        return 'Lớp ${list.filterValue}';
      case ListFilterType.custom:
        return 'Tùy chỉnh';
    }
  }
}
