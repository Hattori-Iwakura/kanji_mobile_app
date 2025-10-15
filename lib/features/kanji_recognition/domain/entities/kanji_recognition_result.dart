// Domain Entity
class KanjiRecognitionResult {
  final String character;
  final double confidence;
  final List<Top5Prediction> top5;

  KanjiRecognitionResult({
    required this.character,
    required this.confidence,
    required this.top5,
  });
}

class Top5Prediction {
  final String character;
  final double confidence;

  Top5Prediction({required this.character, required this.confidence});
}
