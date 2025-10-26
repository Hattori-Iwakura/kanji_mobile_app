import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Reusable drawing canvas widget for quiz DRAWING questions
class QuizDrawingCanvas extends StatefulWidget {
  final Function(Uint8List) onDrawingComplete;
  final VoidCallback? onClear;

  const QuizDrawingCanvas({
    super.key,
    required this.onDrawingComplete,
    this.onClear,
  });

  @override
  State<QuizDrawingCanvas> createState() => _QuizDrawingCanvasState();
}

class _QuizDrawingCanvasState extends State<QuizDrawingCanvas> {
  final List<Offset?> _points = [];
  final GlobalKey _canvasKey = GlobalKey();
  bool _isCapturing = false;

  bool get hasDrawing => _points.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Canvas drawing area
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
                  painter: _CanvasPainter(_points),
                  child: Container(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            // Clear button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasDrawing && !_isCapturing ? _clearCanvas : null,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledForegroundColor: Colors.white24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Submit drawing button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: hasDrawing && !_isCapturing ? _submitDrawing : null,
                icon: _isCapturing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle, size: 20),
                label: Text(_isCapturing ? 'Processing...' : 'Submit Answer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  disabledBackgroundColor: Colors.grey.shade800,
                  disabledForegroundColor: Colors.white38,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Helper text
        Text(
          hasDrawing
              ? 'Draw the kanji character, then tap Submit Answer'
              : 'Use your finger to draw the kanji character above',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
    widget.onClear?.call();
  }

  Future<void> _submitDrawing() async {
    if (!hasDrawing || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      // Capture canvas as image
      final boundary =
          _canvasKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      if (mounted) {
        widget.onDrawingComplete(imageBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing drawing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }
}

/// Custom painter for canvas drawing
class _CanvasPainter extends CustomPainter {
  final List<Offset?> points;

  _CanvasPainter(this.points);

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
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}
