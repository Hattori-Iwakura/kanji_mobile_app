import 'package:equatable/equatable.dart';
import 'kanji_example.dart';

/// Detailed kanji information from external APIs (KanjiAlive, Jisho)
class KanjiDetail extends Equatable {
  final String character;
  final String meanings;
  final String? onyomi;
  final String? kunyomi;
  final int? strokeCount;

  // From KanjiAlive API
  final List<KanjiExample>? examples;
  final String? audioUrl; // Pronunciation audio for the kanji itself
  final String? videoUrl;

  // From KanjiVG
  final List<String>? strokePaths; // SVG paths for stroke order

  // From Jisho
  final String? radicalCharacter;
  final String? radicalMeaning;
  final List<String>? onReadings;
  final List<String>? kunReadings;
  final List<String>? nanoriReadings;

  const KanjiDetail({
    required this.character,
    required this.meanings,
    this.onyomi,
    this.kunyomi,
    this.strokeCount,
    this.examples,
    this.audioUrl,
    this.videoUrl,
    this.strokePaths,
    this.radicalCharacter,
    this.radicalMeaning,
    this.onReadings,
    this.kunReadings,
    this.nanoriReadings,
  });

  @override
  List<Object?> get props => [
    character,
    meanings,
    onyomi,
    kunyomi,
    strokeCount,
    examples,
    audioUrl,
    videoUrl,
    strokePaths,
    radicalCharacter,
    radicalMeaning,
    onReadings,
    kunReadings,
    nanoriReadings,
  ];
}
