import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/delete_kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import 'kanji_detail_page.dart';
import 'kanji_canvas_search_page.dart';
import 'kanji_search_page.dart';

class KanjiListPage extends StatefulWidget {
  const KanjiListPage({super.key});

  @override
  State<KanjiListPage> createState() => _KanjiListPageState();
}

class _KanjiListPageState extends State<KanjiListPage> {
  int? _selectedJLPT;
  int? _selectedGrade;
  bool _isSelectionMode = false;
  final Map<String, int> _selectedKanji = {}; // character -> id

  // Lazy load variables
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentOffset = 0;
  final int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    // Load first batch
    context.read<KanjiBloc>().add(
      LoadKanjiListEvent(limit: _pageSize, offset: 0),
    );

    // Setup scroll listener for lazy loading
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMoreData) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0; // Trigger load more when 200px from bottom

    print(
      'Scroll: current=$currentScroll, max=$maxScroll, hasMore=$_hasMoreData, isLoading=$_isLoadingMore',
    );

    if (maxScroll - currentScroll <= delta) {
      print('Triggering load more at offset $_currentOffset');
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMoreData) return;

    print('Loading more kanji: offset=$_currentOffset, pageSize=$_pageSize');

    setState(() {
      _isLoadingMore = true;
    });

    _currentOffset += _pageSize;

    context.read<KanjiBloc>().add(
      LoadMoreKanjiEvent(
        jlpt: _selectedJLPT,
        grade: _selectedGrade,
        limit: _pageSize,
        offset: _currentOffset,
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedKanji.clear();
      }
    });
  }

  void _toggleKanjiSelection(String character, int id) {
    setState(() {
      if (_selectedKanji.containsKey(character)) {
        _selectedKanji.remove(character);
        if (_selectedKanji.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedKanji[character] = id;
      }
    });
  }

  Future<void> _deleteSelectedKanji() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Delete Kanji',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedKanji.length} kanji?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final deleteKanji = sl<DeleteKanji>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      int successCount = 0;
      int failCount = 0;

      // Show loading indicator
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Deleting ${_selectedKanji.length} kanji...'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 30),
        ),
      );

      // Delete each kanji
      for (final entry in _selectedKanji.entries) {
        final id = entry.value;
        final result = await deleteKanji(id);

        result.fold((failure) => failCount++, (_) => successCount++);
      }

      // Clear selection and show result
      _toggleSelectionMode();
      scaffoldMessenger.clearSnackBars();

      if (successCount > 0) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              failCount > 0
                  ? 'Deleted $successCount kanji, failed $failCount'
                  : 'Successfully deleted $successCount kanji',
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Reload list
        _applyFilters();
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to delete kanji'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showCreateKanjiDialog(BuildContext context) async {
    final characterController = TextEditingController();
    final meaningsController = TextEditingController();
    final onReadingsController = TextEditingController();
    final kunReadingsController = TextEditingController();
    final strokeCountController = TextEditingController();
    final frequencyController = TextEditingController();
    int? selectedJlpt;
    int? selectedGrade;

    // Save the scaffold messenger for later use
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (statefulContext, setState) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F2E),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Create New Kanji',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(dialogContext).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: characterController,
                      label: 'Character *',
                      hint: '漢',
                      maxLength: 1,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: meaningsController,
                      label: 'Meanings *',
                      hint: 'Chinese character, Han',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: onReadingsController,
                      label: 'On Readings *',
                      hint: 'カン',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: kunReadingsController,
                      label: 'Kun Readings *',
                      hint: 'から',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            value: selectedJlpt,
                            label: 'JLPT Level',
                            items: [1, 2, 3, 4, 5],
                            onChanged: (value) {
                              setState(() => selectedJlpt = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            value: selectedGrade,
                            label: 'Grade',
                            items: [1, 2, 3, 4, 5, 6, 8],
                            onChanged: (value) {
                              setState(() => selectedGrade = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: strokeCountController,
                            label: 'Stroke Count *',
                            hint: '12',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: frequencyController,
                            label: 'Frequency *',
                            hint: '100',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (characterController.text.isEmpty ||
                      meaningsController.text.isEmpty ||
                      onReadingsController.text.isEmpty ||
                      kunReadingsController.text.isEmpty ||
                      strokeCountController.text.isEmpty ||
                      frequencyController.text.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all required fields'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      );

      // Save values before disposing controllers
      final character = characterController.text;
      final meanings = meaningsController.text;
      final onReadings = onReadingsController.text;
      final kunReadings = kunReadingsController.text;
      final strokeCount = strokeCountController.text;
      final frequency = frequencyController.text;

      // Only process if user confirmed
      if (result == true && mounted) {
        try {
          final createKanji = sl<CreateKanji>();
          final params = CreateKanjiParams(
            character: character,
            meanings: meanings,
            onReadings: onReadings,
            kunReadings: kunReadings,
            jlptLevel: selectedJlpt,
            grade: selectedGrade,
            strokeCount: int.parse(strokeCount),
            frequency: int.parse(frequency),
          );

          final response = await createKanji(params);

          if (mounted) {
            response.fold(
              (failure) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to create kanji: ${failure.toString()}',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              (kanji) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Created kanji: ${kanji.character}'),
                    backgroundColor: Colors.green,
                  ),
                );
                _applyFilters();
              },
            );
          }
        } catch (e) {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      }
    } finally {
      // Always dispose controllers after dialog is closed
      characterController.dispose();
      meaningsController.dispose();
      onReadingsController.dispose();
      kunReadingsController.dispose();
      strokeCountController.dispose();
      frequencyController.dispose();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
        counterStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }

  Widget _buildDropdown({
    required int? value,
    required String label,
    required List<int> items,
    required void Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
      ),
      dropdownColor: const Color(0xFF1A1F2E),
      style: const TextStyle(color: Colors.white),
      items: items
          .map(
            (item) => DropdownMenuItem<int>(
              value: item,
              child: Text(item.toString()),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin =
            authState is Authenticated && authState.user.role == 'ADMIN';

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
                        // Back Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                            tooltip: 'Back',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.translate,
                            color: Colors.tealAccent,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Kanji',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Canvas Search Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.brush,
                              color: Colors.tealAccent,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const KanjiCanvasSearchPage(),
                                ),
                              );
                              // Reload list when back from canvas search
                              if (mounted) {
                                _applyFilters();
                              }
                            },
                            tooltip: 'Draw to Search',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Text Search Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: Colors.tealAccent,
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const KanjiSearchPage(),
                                ),
                              );
                              // Reload list when back from search
                              if (mounted) {
                                _applyFilters();
                              }
                            },
                            tooltip: 'Search Kanji',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter chips
                  Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // JLPT Filter
                        ...List.generate(5, (index) {
                          final jlpt = index + 1;
                          final isSelected = _selectedJLPT == jlpt;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('N$jlpt'),
                              selected: isSelected,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              selectedColor: Colors.tealAccent.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.tealAccent
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.tealAccent
                                    : Colors.white24,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedJLPT = selected ? jlpt : null;
                                });
                                _applyFilters();
                              },
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        // Grade Filter
                        ...List.generate(6, (index) {
                          final grade = index + 1;
                          final isSelected = _selectedGrade == grade;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('Grade $grade'),
                              selected: isSelected,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              selectedColor: Colors.amberAccent.withOpacity(
                                0.2,
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.amberAccent
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.amberAccent
                                    : Colors.white24,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedGrade = selected ? grade : null;
                                });
                                _applyFilters();
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kanji Grid
                  Expanded(
                    child: BlocBuilder<KanjiBloc, KanjiState>(
                      buildWhen: (previous, current) {
                        // Only rebuild for relevant states
                        return current is KanjiLoading ||
                            current is KanjiError ||
                            current is KanjiListLoaded;
                      },
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
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  state.message,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => _applyFilters(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.tealAccent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is KanjiListLoaded) {
                          final kanjiList = state.kanjiList;

                          if (kanjiList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No kanji found',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Update state when data loaded
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            print(
                              'State update: isLoadingMore=${state.isLoadingMore}, hasMore=${state.hasMore}, kanjiCount=${kanjiList.length}',
                            );

                            if (!state.isLoadingMore && _isLoadingMore) {
                              // BLoC finished loading, update local state
                              setState(() {
                                _isLoadingMore = false;
                              });
                            }
                            if (!state.hasMore && _hasMoreData) {
                              print(
                                'No more data to load - setting _hasMoreData = false',
                              );
                              setState(() {
                                _hasMoreData = false;
                              });
                            }
                          });

                          return CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.85,
                                      ),
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final kanji = kanjiList[index];
                                    final isSelected = _selectedKanji
                                        .containsKey(kanji.character);

                                    return _KanjiCard(
                                      character: kanji.character,
                                      meaning: kanji.meanings
                                          .split(',')
                                          .first
                                          .trim(),
                                      jlpt: kanji.jlpt,
                                      grade: kanji.grade,
                                      isSelected: isSelected,
                                      isSelectionMode: _isSelectionMode,
                                      onTap: () async {
                                        if (_isSelectionMode) {
                                          _toggleKanjiSelection(
                                            kanji.character,
                                            kanji.id,
                                          );
                                        } else {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  KanjiDetailPage(
                                                    character: kanji.character,
                                                  ),
                                            ),
                                          );
                                          if (mounted) {
                                            _applyFilters();
                                          }
                                        }
                                      },
                                      onLongPress: isAdmin
                                          ? () {
                                              if (!_isSelectionMode) {
                                                setState(() {
                                                  _isSelectionMode = true;
                                                  _selectedKanji[kanji
                                                          .character] =
                                                      kanji.id;
                                                });
                                              }
                                            }
                                          : null,
                                    );
                                  }, childCount: kanjiList.length),
                                ),
                              ),
                              // Loading indicator at bottom
                              if (state.isLoadingMore)
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                      color: Colors.tealAccent,
                                    ),
                                  ),
                                ),
                              // End message
                              if (!state.hasMore && kanjiList.isNotEmpty)
                                SliverToBoxAdapter(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'All ${kanjiList.length} kanji loaded',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.translate,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Start exploring kanji',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: isAdmin
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isSelectionMode && _selectedKanji.isNotEmpty)
                      FloatingActionButton.extended(
                        onPressed: _deleteSelectedKanji,
                        backgroundColor: Colors.redAccent,
                        icon: const Icon(Icons.delete),
                        label: Text('Delete ${_selectedKanji.length}'),
                        heroTag: 'delete',
                      ),
                    if (_isSelectionMode) const SizedBox(height: 16),
                    if (_isSelectionMode)
                      FloatingActionButton(
                        onPressed: _toggleSelectionMode,
                        backgroundColor: Colors.white24,
                        child: const Icon(Icons.close),
                        heroTag: 'cancel',
                      ),
                    if (_isSelectionMode) const SizedBox(height: 16),
                    FloatingActionButton(
                      onPressed: () => _showCreateKanjiDialog(context),
                      backgroundColor: Colors.deepPurpleAccent,
                      child: const Icon(Icons.add),
                      heroTag: 'add',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  void _applyFilters() {
    // Reset pagination state
    setState(() {
      _currentOffset = 0;
      _hasMoreData = true;
      _isLoadingMore = false;
    });

    // Load first page with new filters
    context.read<KanjiBloc>().add(
      LoadKanjiListEvent(
        jlpt: _selectedJLPT,
        grade: _selectedGrade,
        limit: _pageSize,
        offset: 0,
      ),
    );
  }
}

class _KanjiCard extends StatelessWidget {
  final String character;
  final String meaning;
  final int? jlpt;
  final int? grade;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  const _KanjiCard({
    required this.character,
    required this.meaning,
    this.jlpt,
    this.grade,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    Colors.deepPurpleAccent.withOpacity(0.3),
                    Colors.purpleAccent.withOpacity(0.2),
                  ]
                : [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurpleAccent
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badges at top
                  if (jlpt != null || grade != null)
                    SizedBox(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (jlpt != null)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.tealAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.tealAccent.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  'N$jlpt',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (jlpt != null && grade != null)
                            const SizedBox(width: 4),
                          if (grade != null)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amberAccent.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  'G$grade',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 20),

                  const SizedBox(height: 4),

                  // Kanji character
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          character,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Meaning
                  SizedBox(
                    height: 28,
                    child: Center(
                      child: Text(
                        meaning,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selection checkbox
            if (isSelectionMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.deepPurpleAccent
                        : Colors.white24,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
