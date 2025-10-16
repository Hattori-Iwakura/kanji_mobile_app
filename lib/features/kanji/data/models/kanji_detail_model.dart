import '../../domain/entities/kanji_detail.dart';
import '../../domain/entities/kanji_progress.dart';
import 'kanji_example_model.dart';
import 'kanji_model.dart';
import 'kanji_progress_model.dart';

class KanjiDetailModel extends KanjiDetail {
  const KanjiDetailModel({
    required super.kanji,
    required super.examples,
    super.progress,
    super.strokeOrder,
    super.components,
  });

  factory KanjiDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse the kanji itself (excluding nested fields)
    final kanjiData = Map<String, dynamic>.from(json);
    kanjiData.remove('Examples');
    kanjiData.remove('Progress');

    final kanji = KanjiModel.fromJson(kanjiData);

    // Parse examples
    final examples = json['Examples'] != null
        ? (json['Examples'] as List)
              .map((e) => KanjiExampleModel.fromJson(e))
              .toList()
        : <KanjiExampleModel>[];

    // Parse progress (if exists)
    KanjiProgress? progress;
    if (json['Progress'] != null) {
      final progressList = json['Progress'] as List;
      if (progressList.isNotEmpty) {
        progress = KanjiProgressModel.fromJson(progressList.first);
      }
    }

    // Parse stroke order and components
    final strokeOrder = json['stroke_order'] as Map<String, dynamic>?;
    final components = json['components'] as Map<String, dynamic>?;

    return KanjiDetailModel(
      kanji: kanji,
      examples: examples,
      progress: progress,
      strokeOrder: strokeOrder,
      components: components,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...(kanji as KanjiModel).toJson(),
      'Examples': examples
          .map((e) => (e as KanjiExampleModel).toJson())
          .toList(),
      if (progress != null)
        'Progress': [(progress as KanjiProgressModel).toJson()],
      if (strokeOrder != null) 'stroke_order': strokeOrder,
      if (components != null) 'components': components,
    };
  }
}
