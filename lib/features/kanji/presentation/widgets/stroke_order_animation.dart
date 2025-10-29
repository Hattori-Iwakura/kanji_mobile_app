import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_drawing/path_drawing.dart';

class StrokeOrderAnimation extends StatefulWidget {
  final List<String> strokePaths;

  const StrokeOrderAnimation({super.key, required this.strokePaths});

  @override
  State<StrokeOrderAnimation> createState() => _StrokeOrderAnimationState();
}

class _StrokeOrderAnimationState extends State<StrokeOrderAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStroke = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_currentStroke < widget.strokePaths.length - 1) {
            _currentStroke++;
            _controller.reset();
            _controller.forward();
          } else {
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playAnimation() {
    setState(() {
      _currentStroke = 0;
      _isPlaying = true;
    });
    _controller.reset();
    _controller.forward();
  }

  void _resetAnimation() {
    setState(() {
      _currentStroke = 0;
      _isPlaying = false;
    });
    _controller.reset();
  }

  void _nextStroke() {
    if (_currentStroke < widget.strokePaths.length - 1) {
      setState(() {
        _currentStroke++;
      });
      _controller.reset();
    }
  }

  void _previousStroke() {
    if (_currentStroke > 0) {
      setState(() {
        _currentStroke--;
      });
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Canvas for drawing strokes
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: CustomPaint(
            painter: StrokePainter(
              strokePaths: widget.strokePaths,
              currentStroke: _currentStroke,
              animationValue: _isPlaying ? _controller.value : 1.0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Stroke counter
        Text(
          'Stroke ${_currentStroke + 1} of ${widget.strokePaths.length}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _currentStroke > 0 ? _previousStroke : null,
              icon: const Icon(Icons.skip_previous),
              color: Colors.tealAccent,
              disabledColor: Colors.grey,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isPlaying ? null : _playAnimation,
              icon: const Icon(Icons.play_arrow),
              color: Colors.tealAccent,
              disabledColor: Colors.grey,
              iconSize: 36,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _resetAnimation,
              icon: const Icon(Icons.replay),
              color: Colors.tealAccent,
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _currentStroke < widget.strokePaths.length - 1
                  ? _nextStroke
                  : null,
              icon: const Icon(Icons.skip_next),
              color: Colors.tealAccent,
              disabledColor: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }
}

class StrokePainter extends CustomPainter {
  final List<String> strokePaths;
  final int currentStroke;
  final double animationValue;

  StrokePainter({
    required this.strokePaths,
    required this.currentStroke,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw completed strokes
    for (int i = 0; i < currentStroke; i++) {
      final path = parseSvgPathData(strokePaths[i]);
      final scaledPath = _scalePath(path, size);
      canvas.drawPath(scaledPath, paint);
    }

    // Draw current stroke with animation
    if (currentStroke < strokePaths.length) {
      final path = parseSvgPathData(strokePaths[currentStroke]);
      final scaledPath = _scalePath(path, size);

      // Create animated path
      final animatedPath = _createAnimatedPath(scaledPath, animationValue);

      // Draw animated stroke in accent color
      final animatedPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(animatedPath, animatedPaint);
    }
  }

  Path _scalePath(Path path, Size size) {
    final bounds = path.getBounds();

    // Prevent division by zero
    if (bounds.width <= 0 ||
        bounds.height <= 0 ||
        size.width <= 0 ||
        size.height <= 0) {
      return path;
    }

    // KanjiVG SVG uses 109x109 viewBox, calculate scale based on that
    final scaleX = size.width / 109;
    final scaleY = size.height / 109;
    var scale = scaleX < scaleY ? scaleX : scaleY;

    // Ensure scale is valid and finite
    if (!scale.isFinite || scale <= 0) {
      return path;
    }

    // Apply padding (80% of available space)
    scale = scale * 0.8;

    // Center the kanji in the canvas
    final offsetX = (size.width - 109 * scale) / 2;
    final offsetY = (size.height - 109 * scale) / 2;

    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale, scale);

    return path.transform(matrix.storage);
  }

  Path _createAnimatedPath(Path path, double value) {
    // Clamp value to valid range
    final clampedValue = value.clamp(0.0, 1.0);

    // Extract path metrics for animation
    final pathMetrics = path.computeMetrics();
    final animatedPath = Path();

    for (var metric in pathMetrics) {
      final length = metric.length;
      if (length <= 0) continue; // Skip empty paths

      final extractPath = metric.extractPath(0.0, length * clampedValue);
      animatedPath.addPath(extractPath, Offset.zero);
    }

    return animatedPath;
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return oldDelegate.currentStroke != currentStroke ||
        oldDelegate.animationValue != animationValue;
  }
}
