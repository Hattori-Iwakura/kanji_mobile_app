import '../../domain/entities/prediction_result.dart';

/// Model for PredictionResult with JSON serialization
class PredictionResultModel extends PredictionResult {
  const PredictionResultModel({
    required super.character,
    required super.confidence,
    required super.rank,
  });

  /// Create model from JSON
  /// Expected format: {"character": "愛", "confidence": 0.95}
  factory PredictionResultModel.fromJson(Map<String, dynamic> json, int rank) {
    return PredictionResultModel(
      character: json['character'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      rank: rank,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {'character': character, 'confidence': confidence, 'rank': rank};
  }

  /// Convert model to entity
  PredictionResult toEntity() {
    return PredictionResult(
      character: character,
      confidence: confidence,
      rank: rank,
    );
  }
}
