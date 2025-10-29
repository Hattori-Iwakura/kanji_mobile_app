import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_event.dart';
import '../bloc/kanji_state.dart';
import 'kanji_detail_page.dart';

class KanjiCanvasSearchPage extends StatefulWidget {
  const KanjiCanvasSearchPage({super.key});

  @override
  State<KanjiCanvasSearchPage> createState() => _KanjiCanvasSearchPageState();
}

class _KanjiCanvasSearchPageState extends State<KanjiCanvasSearchPage> {
  final List<List<Offset>> _strokes = []; // Store strokes separately
  List<Offset> _currentStroke = []; // Current stroke being drawn
  final GlobalKey _canvasKey = GlobalKey();
  bool _isSearching = false;

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
  }

  void _undoLastStroke() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
      // Auto-predict after undo
      if (_strokes.isNotEmpty) {
        _recognizeKanji();
      }
    }
  }

  // Convert strokes to points format for painting
  List<Offset?> get _points {
    final points = <Offset?>[];
    for (final stroke in _strokes) {
      points.addAll(stroke);
      points.add(null); // Null separator between strokes
    }
    if (_currentStroke.isNotEmpty) {
      points.addAll(_currentStroke);
    }
    return points;
  }

  Future<void> _recognizeKanji() async {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw a kanji character first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Capture the canvas as image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(300, 300);

      // Draw black background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black,
      );

      // Draw the strokes in white
      final paint = Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8.0;

      for (int i = 0; i < _points.length - 1; i++) {
        if (_points[i] != null && _points[i + 1] != null) {
          canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // Convert to base64
      final base64Image = 'data:image/png;base64,${base64Encode(buffer)}';

      // Send to BLoC
      if (mounted) {
        context.read<KanjiBloc>().add(SearchByCanvasEvent(base64Image));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Draw Kanji',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Undo Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.undo, color: Colors.orange),
                        onPressed: _strokes.isEmpty ? null : _undoLastStroke,
                        tooltip: 'Undo',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Clear Button
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.redAccent),
                      onPressed: _clearCanvas,
                      tooltip: 'Clear',
                    ),
                  ],
                ),
              ),

              // Canvas Area
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.tealAccent.withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: GestureDetector(
                      key: _canvasKey,
                      onPanUpdate: (details) {
                        setState(() {
                          final RenderBox renderBox =
                              _canvasKey.currentContext!.findRenderObject()
                                  as RenderBox;
                          final localPosition = renderBox.globalToLocal(
                            details.globalPosition,
                          );
                          _currentStroke.add(localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          if (_currentStroke.isNotEmpty) {
                            _strokes.add(List.from(_currentStroke));
                            _currentStroke.clear();
                            // Auto-predict after stroke completion
                            _recognizeKanji();
                          }
                        });
                      },
                      child: CustomPaint(
                        painter: _CanvasPainter(_points),
                        size: const Size(300, 300),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status Indicator
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recognizing...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_strokes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Draw more strokes or tap a result',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // Results Area
              Expanded(
                child: BlocConsumer<KanjiBloc, KanjiState>(
                  listener: (context, state) {
                    if (state is KanjiCanvasSearchLoaded) {
                      setState(() {
                        _isSearching = false;
                      });
                    } else if (state is KanjiError) {
                      setState(() {
                        _isSearching = false;
                      });
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
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      );
                    }

                    if (state is KanjiCanvasSearchLoaded) {
                      final results = state.results;

                      if (results.isEmpty) {
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
                                'No kanji recognized',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Recognition Results',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.tealAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final kanji = results[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => BlocProvider.value(
                                          value: context.read<KanjiBloc>(),
                                          child: KanjiDetailPage(
                                            character: kanji.character,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Kanji character
                                        Text(
                                          kanji.character,
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Meaning
                                        Text(
                                          kanji.meanings
                                              .split(',')
                                              .first
                                              .trim(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                            Icons.gesture,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Draw a kanji character\nand tap Recognize',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
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
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<Offset?> points;

  _CanvasPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}
