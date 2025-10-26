import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../cnn_recognition/presentation/bloc/cnn_recognition_bloc.dart';
import '../../../cnn_recognition/presentation/bloc/cnn_recognition_event.dart';
import '../../../cnn_recognition/presentation/bloc/cnn_recognition_state.dart';
import '../../domain/entities/kanji.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import 'kanji_detail_page.dart';

/// Kanji Search Page with integrated canvas drawing (like Jisho.org)
class KanjiSearchPage extends StatefulWidget {
  const KanjiSearchPage({super.key});

  @override
  State<KanjiSearchPage> createState() => _KanjiSearchPageState();
}

class _KanjiSearchPageState extends State<KanjiSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCanvas = false;
  bool _showFilters = false; // Toggle advanced filters

  // Filter state
  final List<int> _selectedJlptLevels = [];
  final List<int> _selectedGrades = [];
  int? _minStrokes;
  int? _maxStrokes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<KanjiBloc>()),
        BlocProvider(create: (_) => getIt<CnnRecognitionBloc>()),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Search Kanji',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Search bar with canvas toggle button
            _buildSearchBar(),

            // Advanced filter chips (collapsible)
            if (_showFilters) _buildFilterSection(),

            // Canvas drawing panel (collapsible)
            if (_showCanvas) _buildCanvasPanel(),

            // Search results
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Canvas toggle button (like Jisho.org)
          Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showCanvas ? Colors.blue : Colors.white24,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.draw,
                color: _showCanvas ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showCanvas = !_showCanvas;
                });
                if (_showCanvas) {
                  // Initialize CNN recognition when opening canvas
                  context.read<CnnRecognitionBloc>().add(
                    CheckServerStatusEvent(),
                  );
                }
              },
              tooltip: 'Draw kanji',
            ),
          ),
          const SizedBox(width: 12),

          // Search text field
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search by character, meaning, or reading...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          context.read<KanjiBloc>().add(
                            const LoadAllKanjiEvent(),
                          );
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
                } else {
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (value == _searchController.text) {
                      context.read<KanjiBloc>().add(
                        SearchKanjiEvent(query: value),
                      );
                    }
                  });
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<KanjiBloc>().add(SearchKanjiEvent(query: value));
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Filter toggle button
          Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _showFilters ? Colors.blue : Colors.white24,
                width: 2,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _showFilters ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              tooltip: 'Advanced filters',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JLPT Level filters
          Text(
            'JLPT Level',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 4, 3, 2, 1].map((level) {
              final isSelected = _selectedJlptLevels.contains(level);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedJlptLevels.remove(level);
                    } else {
                      _selectedJlptLevels.add(level);
                    }
                  });
                  _applyFilters();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'N$level',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.8),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Grade filters
          Text(
            'School Grade',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1, 2, 3, 4, 5, 6].map((grade) {
              final isSelected = _selectedGrades.contains(grade);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGrades.remove(grade);
                    } else {
                      _selectedGrades.add(grade);
                    }
                  });
                  _applyFilters();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'G$grade',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.8),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Stroke count filters
          Text(
            'Stroke Count',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Min',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minStrokes = int.tryParse(value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Max',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxStrokes = int.tryParse(value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clear filters button
          if (_selectedJlptLevels.isNotEmpty ||
              _selectedGrades.isNotEmpty ||
              _minStrokes != null ||
              _maxStrokes != null)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedJlptLevels.clear();
                    _selectedGrades.clear();
                    _minStrokes = null;
                    _maxStrokes = null;
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear, color: Colors.red),
                label: const Text(
                  'Clear All Filters',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _applyFilters() {
    final query = _searchController.text.trim();
    context.read<KanjiBloc>().add(
      SearchKanjiEvent(
        query: query.isEmpty ? null : query,
        jlptLevels: _selectedJlptLevels.isEmpty ? null : _selectedJlptLevels,
        grades: _selectedGrades.isEmpty ? null : _selectedGrades,
        minStrokes: _minStrokes,
        maxStrokes: _maxStrokes,
      ),
    );
  }

  Widget _buildCanvasPanel() {
    return BlocListener<CnnRecognitionBloc, CnnRecognitionState>(
      listener: (context, state) {
        if (state is ServerUnavailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          children: [
            // Server status
            BlocBuilder<CnnRecognitionBloc, CnnRecognitionState>(
              builder: (context, state) {
                if (state is ServerAvailable) {
                  return _buildStatusIndicator(
                    'CNN server ready',
                    Colors.green,
                    Icons.check_circle,
                  );
                } else if (state is ServerUnavailable) {
                  return _buildStatusIndicator(
                    'CNN server offline',
                    Colors.orange,
                    Icons.warning,
                  );
                } else if (state is CheckingServerStatus) {
                  return _buildStatusIndicator(
                    'Checking server...',
                    Colors.blue,
                    Icons.sync,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Canvas drawing area
            const _DrawingCanvas(),

            // Prediction results in horizontal scroll
            BlocBuilder<CnnRecognitionBloc, CnnRecognitionState>(
              builder: (context, state) {
                if (state is PredictingKanji) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Analyzing...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PredictionSuccess) {
                  return Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.predictions.length > 10
                          ? 10
                          : state.predictions.length,
                      itemBuilder: (context, index) {
                        final prediction = state.predictions[index];
                        return _buildPredictionCard(prediction.character);
                      },
                    ),
                  );
                }

                if (state is PredictionError) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Draw a kanji above to see predictions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(String character) {
    return GestureDetector(
      onTap: () {
        // Insert character into search field and trigger search
        _searchController.text = character;
        context.read<KanjiBloc>().add(SearchKanjiEvent(query: character));
        setState(() {
          _showCanvas = false; // Close canvas after selection
        });
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Center(
          child: Text(
            character,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Noto Sans JP',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<KanjiBloc, KanjiState>(
      builder: (context, state) {
        if (state is KanjiLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state is KanjiSearchLoaded) {
          if (state.results.isEmpty) {
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
                  Text(
                    'No kanji found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_searchController.text.isNotEmpty) {
                context.read<KanjiBloc>().add(
                  SearchKanjiEvent(query: _searchController.text),
                );
              } else {
                context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
              }
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final kanji = state.results[index];
                return _buildKanjiCard(
                  context,
                  kanji: kanji,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KanjiDetailPage(kanji: kanji),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        if (state is KanjiListLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: state.kanjiList.length,
              itemBuilder: (context, index) {
                final kanji = state.kanjiList[index];
                return _buildKanjiCard(
                  context,
                  kanji: kanji,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KanjiDetailPage(kanji: kanji),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        if (state is KanjiError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<KanjiBloc>().add(const LoadAllKanjiEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Initial state - show prompt
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Search for kanji',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type in the search bar or draw using the pen icon',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build kanji card widget
  Widget _buildKanjiCard(
    BuildContext context, {
    required Kanji kanji,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kanji character
              Text(
                kanji.character,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans JP',
                ),
              ),
              const SizedBox(height: 8),

              // Meaning
              Text(
                kanji.meanings.split(',').first.trim(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Readings
              if (kanji.onyomi != null || kanji.kunyomi != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (kanji.onyomi != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kanji.onyomi!,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (kanji.kunyomi != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kanji.kunyomi!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Drawing canvas widget (compact version for search)
class _DrawingCanvas extends StatefulWidget {
  const _DrawingCanvas();

  @override
  State<_DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<_DrawingCanvas> {
  final List<Offset?> _points = [];
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Canvas
        Container(
          height: 200,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _points.add(details.localPosition));
              },
              onPanUpdate: (details) {
                setState(() => _points.add(details.localPosition));
              },
              onPanEnd: (details) {
                setState(() => _points.add(null));
              },
              child: RepaintBoundary(
                key: _canvasKey,
                child: CustomPaint(
                  painter: _DrawingPainter(_points),
                  child: Container(),
                ),
              ),
            ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _points.clear());
                    context.read<CnnRecognitionBloc>().add(
                      ClearRecognitionEvent(),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: BlocBuilder<CnnRecognitionBloc, CnnRecognitionState>(
                  builder: (context, state) {
                    final isLoading = state is PredictingKanji;
                    final canPredict =
                        _points.length > 5 && state is! ServerUnavailable;

                    return ElevatedButton.icon(
                      onPressed: canPredict && !isLoading
                          ? () => _predictKanji(context)
                          : null,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(isLoading ? 'Analyzing...' : 'Recognize'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.white24,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _predictKanji(BuildContext context) async {
    try {
      final boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      if (mounted) {
        context.read<CnnRecognitionBloc>().add(PredictKanjiEvent(imageBytes));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

/// Custom painter for drawing
class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DrawingPainter oldDelegate) => true;
}
