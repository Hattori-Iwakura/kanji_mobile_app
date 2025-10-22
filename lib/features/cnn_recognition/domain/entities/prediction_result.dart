import 'package:equatable/equatable.dart';

/// Entity representing a single prediction result from CNN model
class PredictionResult extends Equatable {
  final String character;
  final double confidence;
  final int rank; // 1-5 for top 5 predictions

  const PredictionResult({
    required this.character,
    required this.confidence,
    required this.rank,
  });

  @override
  List<Object?> get props => [character, confidence, rank];

  /// Get confidence as percentage string (e.g., "95.3%")
  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if confidence is high (>70%)
  bool get isHighConfidence => confidence > 0.7;
}
