import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../kanji/presentation/bloc/kanji_bloc.dart';
import '../../../kanji/presentation/bloc/kanji_event.dart';
import '../../../kanji/presentation/bloc/kanji_state.dart';
import '../bloc/kanji_table_bloc.dart';
import '../bloc/kanji_table_event.dart';

class AddKanjiToTablePage extends StatefulWidget {
  final int tableId;
  final String tableName;
  final List<int> existingKanjiIds;

  const AddKanjiToTablePage({
    super.key,
    required this.tableId,
    required this.tableName,
    this.existingKanjiIds = const [],
  });

  @override
  State<AddKanjiToTablePage> createState() => _AddKanjiToTablePageState();
}

class _AddKanjiToTablePageState extends State<AddKanjiToTablePage> {
  final _searchController = TextEditingController();
  String? _selectedJlptLevel;
  final Set<int> _selectedKanjiIds = {};

  @override
  void initState() {
    super.initState();
    _loadKanji();
  }

  void _loadKanji() {
    if (_selectedJlptLevel != null) {
      context.read<KanjiBloc>().add(
        LoadKanjiListEvent(
          jlpt: int.parse(_selectedJlptLevel!.substring(1)),
          limit: 10000, // Load all kanji
        ),
      );
    } else if (_searchController.text.isNotEmpty) {
      context.read<KanjiBloc>().add(
        SearchKanjiEvent(query: _searchController.text),
      );
    } else {
      context.read<KanjiBloc>().add(
        const LoadKanjiListEvent(limit: 10000), // Load all kanji
      );
    }
  }

  void _searchKanji(String query) {
    if (query.isEmpty) {
      context.read<KanjiBloc>().add(
        const LoadKanjiListEvent(limit: 10000), // Load all kanji
      );
    } else {
      context.read<KanjiBloc>().add(SearchKanjiEvent(query: query));
    }
  }

  void _filterByJlpt(String? level) {
    setState(() {
      _selectedJlptLevel = level;
      _searchController.clear();
    });
    if (level != null) {
      context.read<KanjiBloc>().add(
        LoadKanjiListEvent(
          jlpt: int.parse(level.substring(1)),
          limit: 10000, // Load all kanji
        ),
      );
    } else {
      context.read<KanjiBloc>().add(
        const LoadKanjiListEvent(limit: 10000), // Load all kanji
      );
    }
  }

  void _addSelectedKanji() {
    if (_selectedKanjiIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one kanji')),
      );
      return;
    }

    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adding ${_selectedKanjiIds.length} kanji to table...'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Add each selected kanji
    for (final kanjiId in _selectedKanjiIds) {
      context.read<KanjiTableBloc>().add(
        AddKanjiToTableEvent(tableId: widget.tableId, kanjiId: kanjiId),
      );
    }

    // Go back immediately
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071126), Color(0xFF0B0F14)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.tealAccent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Kanji',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'to "${widget.tableName}"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedKanjiIds.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.tealAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_selectedKanjiIds.length} selected',
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.tealAccent.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search kanji...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.tealAccent.withOpacity(0.7),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchKanji('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _searchKanji,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // JLPT filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    const SizedBox(width: 8),
                    ...['N5', 'N4', 'N3', 'N2', 'N1'].map((level) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip('JLPT $level', level),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kanji grid
              Expanded(
                child: BlocBuilder<KanjiBloc, KanjiState>(
                  builder: (context, state) {
                    if (state is KanjiLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      );
                    }

                    if (state is KanjiError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadKanji,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent,
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is KanjiListLoaded ||
                        state is KanjiSearchResult) {
                      // Get kanji list from either state
                      final kanjiList = state is KanjiListLoaded
                          ? state.kanjiList
                          : (state as KanjiSearchResult).kanjiList;

                      // Filter out kanji that are already in the table
                      final availableKanji = kanjiList
                          .where((k) => !widget.existingKanjiIds.contains(k.id))
                          .toList();

                      if (availableKanji.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.tealAccent.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No more kanji to add',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: availableKanji.length,
                        itemBuilder: (context, index) {
                          final kanji = availableKanji[index];
                          final isSelected = _selectedKanjiIds.contains(
                            kanji.id,
                          );

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedKanjiIds.remove(kanji.id);
                                } else {
                                  _selectedKanjiIds.add(kanji.id);
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.tealAccent,
                                          Color(0xFF00BFA5),
                                        ],
                                      )
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.tealAccent.withOpacity(0.1),
                                          const Color(
                                            0xFF1DE9B6,
                                          ).withOpacity(0.05),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.tealAccent
                                      : Colors.tealAccent.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.tealAccent.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              kanji.character,
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            kanji.meanings,
                                            style: TextStyle(
                                              fontSize: 7,
                                              color: isSelected
                                                  ? Colors.black87
                                                  : Colors.white70,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (kanji.jlpt != null)
                                          Text(
                                            'N${kanji.jlpt}',
                                            style: TextStyle(
                                              fontSize: 6,
                                              color: isSelected
                                                  ? Colors.black54
                                                  : Colors.white54,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedKanjiIds.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.tealAccent, Color(0xFF00BFA5)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _addSelectedKanji,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text(
                  'Add ${_selectedKanjiIds.length}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final isSelected = _selectedJlptLevel == value;
    return GestureDetector(
      onTap: () => _filterByJlpt(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Colors.tealAccent, Color(0xFF00BFA5)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.tealAccent
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
