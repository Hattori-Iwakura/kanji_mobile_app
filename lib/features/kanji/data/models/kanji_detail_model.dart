import '../../domain/entities/kanji_detail.dart';
import '../../domain/entities/kanji_example.dart';

class KanjiDetailModel extends KanjiDetail {
  const KanjiDetailModel({
    required super.character,
    required super.meanings,
    super.onyomi,
    super.kunyomi,
    super.strokeCount,
    super.examples,
    super.audioUrl,
    super.videoUrl,
    super.strokePaths,
    super.radicalCharacter,
    super.radicalMeaning,
    super.onReadings,
    super.kunReadings,
    super.nanoriReadings,
  });

  factory KanjiDetailModel.fromMultipleSources({
    required String character,
    required String meanings,
    String? onyomi,
    String? kunyomi,
    int? strokeCount,
    Map<String, dynamic>? kanjiAliveData,
    Map<String, dynamic>? jishoData,
    List<String>? strokePaths,
  }) {
    // Extract from KanjiAlive
    List<KanjiExample>? examples;
    String? audioUrl;
    String? videoUrl;

    if (kanjiAliveData != null) {
      if (kanjiAliveData['examples'] != null) {
        examples = (kanjiAliveData['examples'] as List)
            .map(
              (e) => KanjiExample(
                japanese: e['japanese'] as String? ?? '',
                meaning: e['meaning']?['english'] as String? ?? '',
                audioUrl: e['audio']?['mp3'] as String?,
              ),
            )
            .toList()
            .cast<KanjiExample>();
      }

      // Get pronunciation audio for the kanji itself
      if (kanjiAliveData['kanji']?['video'] != null) {
        videoUrl = kanjiAliveData['kanji']['video']['mp4'] as String?;
      }
    }

    // Extract from Jisho
    String? radicalCharacter;
    String? radicalMeaning;
    List<String>? onReadings;
    List<String>? kunReadings;
    List<String>? nanoriReadings;

    if (jishoData != null && jishoData['data'] != null) {
      final data = jishoData['data'] as List;
      if (data.isNotEmpty) {
        final firstResult = data[0];

        // Get readings
        if (firstResult['japanese'] != null) {
          final japanese = firstResult['japanese'] as List;
          onReadings = [];
          kunReadings = [];

          for (var reading in japanese) {
            if (reading['reading'] != null) {
              // Jisho doesn't separate on/kun clearly, we'll need to parse
              final readingStr = reading['reading'] as String;
              // Simple heuristic: hiragana = kun, katakana = on
              if (readingStr.runes.every((r) => r >= 0x3040 && r <= 0x309F)) {
                kunReadings.add(readingStr);
              } else {
                onReadings.add(readingStr);
              }
            }
          }
        }
      }
    }

    return KanjiDetailModel(
      character: character,
      meanings: meanings,
      onyomi: onyomi,
      kunyomi: kunyomi,
      strokeCount: strokeCount,
      examples: examples,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      strokePaths: strokePaths,
      radicalCharacter: radicalCharacter,
      radicalMeaning: radicalMeaning,
      onReadings: onReadings,
      kunReadings: kunReadings,
      nanoriReadings: nanoriReadings,
    );
  }
}
