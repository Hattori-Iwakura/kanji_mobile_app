import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../kanji/presentation/bloc/kanji_bloc.dart';
import '../../../kanji/presentation/bloc/kanji_event.dart';
import '../../../kanji/presentation/bloc/kanji_state.dart';
import '../bloc/flashcard_bloc.dart';
import '../bloc/flashcard_event.dart';

class AddKanjiToDeckPage extends StatefulWidget {
  final int deckId;
  final String deckName;
  final List<int> existingKanjiIds;

  const AddKanjiToDeckPage({
    super.key,
    required this.deckId,
    required this.deckName,
    this.existingKanjiIds = const [],
  });

  @override
  State<AddKanjiToDeckPage> createState() => _AddKanjiToDeckPageState();
}

class _AddKanjiToDeckPageState extends State<AddKanjiToDeckPage> {
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
        LoadKanjiListEvent(jlpt: int.parse(_selectedJlptLevel!.substring(1))),
      );
    } else if (_searchController.text.isNotEmpty) {
      context.read<KanjiBloc>().add(
        SearchKanjiEvent(query: _searchController.text),
      );
    } else {
      context.read<KanjiBloc>().add(const LoadKanjiListEvent());
    }
  }

  void _searchKanji(String query) {
    if (query.isEmpty) {
      context.read<KanjiBloc>().add(const LoadKanjiListEvent());
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
        LoadKanjiListEvent(jlpt: int.parse(level.substring(1))),
      );
    } else {
      context.read<KanjiBloc>().add(const LoadKanjiListEvent());
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
        content: Text('Adding ${_selectedKanjiIds.length} kanji to deck...'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Add each selected kanji
    for (final kanjiId in _selectedKanjiIds) {
      context.read<FlashcardBloc>().add(
        AddCardToDeckEvent(deckId: widget.deckId, kanjiId: kanjiId),
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
              // Custom app bar
              Padding(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(width: 16),
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
                            'to "${widget.deckName}"',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          gradient: const LinearGradient(
                            colors: [Colors.tealAccent, Color(0xFF00BFA5)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedKanjiIds.length} selected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      hintText:
                          'Search kanji by character, meaning, or reading...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadKanji,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
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

                      // Filter out kanji that are already in the deck
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
                              const SizedBox(height: 8),
                              const Text(
                                'All kanji matching the filter\nare already in this deck',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
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
                                          Colors.white.withOpacity(0.05),
                                          Colors.white.withOpacity(0.02),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.tealAccent
                                      : Colors.white.withOpacity(0.1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
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
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(
                                                        0.9,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Flexible(
                                          child: Text(
                                            kanji.meanings,
                                            style: TextStyle(
                                              fontSize: 8,
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.9,
                                                    )
                                                  : Colors.white.withOpacity(
                                                      0.6,
                                                    ),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        if (kanji.jlpt != null)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.2,
                                                    )
                                                  : Colors.tealAccent
                                                        .withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'N${kanji.jlpt}',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.tealAccent,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF00BFA5),
                                          size: 20,
                                        ),
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
          ? FloatingActionButton.extended(
              onPressed: _addSelectedKanji,
              icon: const Icon(Icons.add),
              label: Text('Add ${_selectedKanjiIds.length}'),
              backgroundColor: Colors.tealAccent,
              foregroundColor: Colors.white,
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
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
