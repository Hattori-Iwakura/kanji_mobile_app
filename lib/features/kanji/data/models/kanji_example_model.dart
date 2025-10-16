import '../../domain/entities/kanji_example.dart';

class KanjiExampleModel extends KanjiExample {
  const KanjiExampleModel({
    required super.id,
    required super.kanjiId,
    required super.word,
    required super.reading,
    required super.meaning,
    super.wordType,
    super.jlptLevel,
    super.frequency,
    required super.createAt,
  });

  factory KanjiExampleModel.fromJson(Map<String, dynamic> json) {
    return KanjiExampleModel(
      id: json['id'] as int,
      kanjiId: json['kanji_id'] as int,
      word: json['word'] as String,
      reading: json['reading'] as String,
      meaning: json['meaning'] as String,
      wordType: json['word_type'] as String?,
      jlptLevel: json['jlpt_level'] as int?,
      frequency: json['frequency'] as int?,
      createAt: DateTime.parse(json['create_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kanji_id': kanjiId,
      'word': word,
      'reading': reading,
      'meaning': meaning,
      'word_type': wordType,
      'jlpt_level': jlptLevel,
      'frequency': frequency,
      'create_at': createAt.toIso8601String(),
    };
  }
}
