import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/cnn_recognition_bloc.dart';
import '../bloc/cnn_recognition_event.dart';
import '../bloc/cnn_recognition_state.dart';
import '../widgets/prediction_result_grid.dart';

/// Page for drawing kanji and getting AI predictions
class KanjiDrawingPage extends StatelessWidget {
  const KanjiDrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CnnRecognitionBloc>()..add(CheckServerStatusEvent()),
      child: const _KanjiDrawingView(),
    );
  }
}

class _KanjiDrawingView extends StatefulWidget {
  const _KanjiDrawingView();

  @override
  State<_KanjiDrawingView> createState() => _KanjiDrawingViewState();
}

class _KanjiDrawingViewState extends State<_KanjiDrawingView> {
  final List<Offset?> _points = [];
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Kanji Recognition',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearCanvas,
            tooltip: 'Clear',
          ),
        ],
      ),
      body: BlocListener<CnnRecognitionBloc, CnnRecognitionState>(
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
        child: Column(
          children: [
            // Server status indicator
            BlocBuilder<CnnRecognitionBloc, CnnRecognitionState>(
              builder: (context, state) {
                if (state is CheckingServerStatus) {
                  return _buildStatusBanner(
                    'Checking CNN server...',
                    Colors.blue,
                    icon: Icons.sync,
                  );
                } else if (state is ServerAvailable) {
                  return _buildStatusBanner(
                    'CNN server ready',
                    Colors.green,
                    icon: Icons.check_circle,
                  );
                } else if (state is ServerUnavailable) {
                  return _buildStatusBanner(
                    'CNN server offline',
                    Colors.orange,
                    icon: Icons.warning,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Drawing canvas
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _points.add(null); // Add null to separate strokes
                      });
                    },
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: CustomPaint(
                        painter: DrawingPainter(_points),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clearCanvas,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: BlocBuilder<CnnRecognitionBloc, CnnRecognitionState>(
                      builder: (context, state) {
                        final isLoading = state is PredictingKanji;
                        final canPredict =
                            _points.length > 5 && state is! ServerUnavailable;

                        return ElevatedButton.icon(
                          onPressed: canPredict && !isLoading
                              ? _predictKanji
                              : null,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(isLoading ? 'Analyzing...' : 'Recognize'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: Colors.white24,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prediction results
            Expanded(
              flex: 2,
              child: BlocBuilder<CnnRecognitionBloc, CnnRecognitionState>(
                builder: (context, state) {
                  if (state is PredictingKanji) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Analyzing your drawing...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is PredictionSuccess) {
                    return PredictionResultGrid(predictions: state.predictions);
                  }

                  if (state is PredictionError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CnnRecognitionBloc>().add(
                                CheckServerStatusEvent(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Initial state - show instructions
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.draw,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Draw a kanji character above',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Use your finger to draw in the white box,\nthen tap "Recognize" to see predictions',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
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
        ),
      ),
    );
  }

  Widget _buildStatusBanner(
    String text,
    Color color, {
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
    context.read<CnnRecognitionBloc>().add(ClearRecognitionEvent());
  }

  Future<void> _predictKanji() async {
    try {
      // Capture the canvas as image
      final boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      // Send to BLoC
      if (mounted) {
        context.read<CnnRecognitionBloc>().add(PredictKanjiEvent(imageBytes));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Custom painter for drawing strokes
class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
