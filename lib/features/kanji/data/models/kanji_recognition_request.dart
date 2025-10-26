import 'package:equatable/equatable.dart';

/// Request model for kanji recognition from canvas drawing
class KanjiRecognitionRequest extends Equatable {
  /// Base64 encoded image from canvas drawing
  /// Format: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
  final String image;

  const KanjiRecognitionRequest({required this.image});

  Map<String, dynamic> toJson() {
    return {'image': image};
  }

  @override
  List<Object?> get props => [image];
}
