import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/kanji_recognition_bloc.dart';
import '../bloc/kanji_recognition_event.dart';
import '../bloc/kanji_recognition_state.dart';

class KanjiDrawingPage extends StatefulWidget {
  const KanjiDrawingPage({super.key});

  @override
  State<KanjiDrawingPage> createState() => _KanjiDrawingPageState();
}

class _KanjiDrawingPageState extends State<KanjiDrawingPage> {
  final List<DrawingPoint?> _points = [];
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kanji Recognition'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCanvas,
            tooltip: 'Clear',
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas drawing area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[700]!, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.black, // Changed to black background
              ),
              child: RepaintBoundary(
                key: _canvasKey,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _points.add(
                        DrawingPoint(
                          offset: details.localPosition,
                          paint: Paint()
                            ..color = Colors
                                .white // Changed to white stroke
                            ..strokeWidth = 8
                            ..strokeCap = StrokeCap.round,
                        ),
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _points.add(
                        DrawingPoint(
                          offset: details.localPosition,
                          paint: Paint()
                            ..color = Colors
                                .white // Changed to white stroke
                            ..strokeWidth = 8
                            ..strokeCap = StrokeCap.round,
                        ),
                      );
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _points.add(null); // Add null to separate strokes
                    });
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(_points),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

          // Recognition button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _points.isEmpty ? null : _recognizeKanji,
                icon: const Icon(Icons.check_circle),
                label: const Text('Recognize'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[800],
                ),
              ),
            ),
          ),

          // Recognition result
          Expanded(
            flex: 2,
            child: BlocBuilder<KanjiRecognitionBloc, KanjiRecognitionState>(
              builder: (context, state) {
                if (state is KanjiRecognitionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                }

                if (state is KanjiRecognitionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is KanjiRecognitionSuccess) {
                  final result = state.result;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top prediction
                        Card(
                          color: Colors.grey[900],
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  result.character,
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Top Prediction',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Confidence: ${(result.confidence * 100).toStringAsFixed(2)}%',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Top 5 predictions
                        const Text(
                          'Top 5 Predictions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...result.top5.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final prediction = entry.value;
                          return Card(
                            color: Colors.grey[850],
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '$index',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                prediction.character,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '${(prediction.confidence * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text(
                    'Draw a kanji character above\nand tap "Recognize"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
    context.read<KanjiRecognitionBloc>().add(ClearRecognitionEvent());
  }

  Future<void> _recognizeKanji() async {
    try {
      // Convert canvas to image
      final boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Convert to base64
      final base64Image = 'data:image/png;base64,${base64Encode(pngBytes)}';

      // Trigger recognition
      if (mounted) {
        context.read<KanjiRecognitionBloc>().add(
          RecognizeKanjiEvent(base64Image),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}

// Drawing point class
class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

// Custom painter for drawing
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
