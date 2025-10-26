import 'package:equatable/equatable.dart';

/// Top 5 prediction entity
class Top5Prediction extends Equatable {
  final String character;
  final double confidence;

  const Top5Prediction({required this.character, required this.confidence});

  @override
  List<Object?> get props => [character, confidence];
}

/// Kanji recognition result entity
class KanjiRecognitionResultEntity extends Equatable {
  final String character;
  final double confidence;
  final List<Top5Prediction>? top5;

  const KanjiRecognitionResultEntity({
    required this.character,
    required this.confidence,
    this.top5,
  });

  @override
  List<Object?> get props => [character, confidence, top5];
}
