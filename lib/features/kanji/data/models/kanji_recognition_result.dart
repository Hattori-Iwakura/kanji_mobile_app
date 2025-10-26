import 'package:equatable/equatable.dart';

/// Single prediction result with character and confidence
class Top5Prediction extends Equatable {
  final String character;
  final double confidence;

  const Top5Prediction({required this.character, required this.confidence});

  factory Top5Prediction.fromJson(Map<String, dynamic> json) {
    return Top5Prediction(
      character: json['character'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'character': character, 'confidence': confidence};
  }

  @override
  List<Object?> get props => [character, confidence];
}

/// Result model for kanji recognition
class KanjiRecognitionResult extends Equatable {
  /// Top predicted kanji character
  final String character;

  /// Confidence score (0-1)
  final double confidence;

  /// Top 5 predictions with confidence scores (optional)
  final List<Top5Prediction>? top5;

  const KanjiRecognitionResult({
    required this.character,
    required this.confidence,
    this.top5,
  });

  factory KanjiRecognitionResult.fromJson(Map<String, dynamic> json) {
    return KanjiRecognitionResult(
      character: json['character'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      top5: json['top5'] != null
          ? (json['top5'] as List)
                .map((e) => Top5Prediction.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'confidence': confidence,
      if (top5 != null) 'top5': top5!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [character, confidence, top5];
}
