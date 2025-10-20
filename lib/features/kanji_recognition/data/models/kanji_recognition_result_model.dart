import '../../domain/entities/kanji_recognition_result.dart';

// Data Model
class KanjiRecognitionResultModel extends KanjiRecognitionResult {
  KanjiRecognitionResultModel({
    required super.character,
    required super.confidence,
    required super.top5,
  });

  factory KanjiRecognitionResultModel.fromJson(Map<String, dynamic> json) {
    return KanjiRecognitionResultModel(
      character: json['character'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      top5:
          (json['top5'] as List<dynamic>?)
              ?.map((item) => Top5PredictionModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'confidence': confidence,
      'top5': top5
          .map((item) => (item as Top5PredictionModel).toJson())
          .toList(),
    };
  }
}

class Top5PredictionModel extends Top5Prediction {
  Top5PredictionModel({required super.character, required super.confidence});

  factory Top5PredictionModel.fromJson(Map<String, dynamic> json) {
    return Top5PredictionModel(
      character: json['character'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'character': character, 'confidence': confidence};
  }
}
