import 'package:equatable/equatable.dart';
import 'kanji.dart';
import 'kanji_example.dart';
import 'kanji_progress.dart';

class KanjiDetail extends Equatable {
  final Kanji kanji;
  final List<KanjiExample> examples;
  final KanjiProgress? progress;
  final Map<String, dynamic>? strokeOrder; // JSON data for stroke animation
  final Map<String, dynamic>? components; // Component breakdown

  const KanjiDetail({
    required this.kanji,
    required this.examples,
    this.progress,
    this.strokeOrder,
    this.components,
  });

  // Check if user has progress for this kanji
  bool get hasProgress => progress != null;

  // Get progress status or default to new
  ProgressStatus get status => progress?.status ?? ProgressStatus.newKanji;

  // Get example count
  int get exampleCount => examples.length;

  @override
  List<Object?> get props => [
    kanji,
    examples,
    progress,
    strokeOrder,
    components,
  ];
}
