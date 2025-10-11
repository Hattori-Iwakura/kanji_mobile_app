class Kanji {
  final int id;
  final String character;
  final String meanings;
  final String? onyomi;
  final String? kunyomi;
  final int? strokeCount;
  final int? jlpt;
  final int? grade;
  final int? frequency;
  final String? radicals;

  Kanji({
    required this.id,
    required this.character,
    required this.meanings,
    this.onyomi,
    this.kunyomi,
    this.strokeCount,
    this.jlpt,
    this.grade,
    this.frequency,
    this.radicals,
  });

  factory Kanji.fromJson(Map<String, dynamic> json) {
    return Kanji(
      id: json['id'],
      character: json['character'],
      meanings: json['meanings'],
      onyomi: json['onyomi'],
      kunyomi: json['kunyomi'],
      strokeCount: json['stroke_count'],
      jlpt: json['jlpt'],
      grade: json['grade'],
      frequency: json['frequency'],
      radicals: json['radicals'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'meanings': meanings,
      'onyomi': onyomi,
      'kunyomi': kunyomi,
      'stroke_count': strokeCount,
      'jlpt': jlpt,
      'grade': grade,
      'frequency': frequency,
      'radicals': radicals,
    };
  }

  Kanji copyWith({
    int? id,
    String? character,
    String? meanings,
    String? onyomi,
    String? kunyomi,
    int? strokeCount,
    int? jlpt,
    int? grade,
    int? frequency,
    String? radicals,
  }) {
    return Kanji(
      id: id ?? this.id,
      character: character ?? this.character,
      meanings: meanings ?? this.meanings,
      onyomi: onyomi ?? this.onyomi,
      kunyomi: kunyomi ?? this.kunyomi,
      strokeCount: strokeCount ?? this.strokeCount,
      jlpt: jlpt ?? this.jlpt,
      grade: grade ?? this.grade,
      frequency: frequency ?? this.frequency,
      radicals: radicals ?? this.radicals,
    );
  }

  // Helper methods for search
  List<String> get meaningsList {
    return meanings.split(',').map((m) => m.trim()).toList();
  }

  List<String> get onyomiList {
    return onyomi?.split(',').map((o) => o.trim()).toList() ?? [];
  }

  List<String> get kunyomiList {
    return kunyomi?.split(',').map((k) => k.trim()).toList() ?? [];
  }
}
