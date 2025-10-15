import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class UpdateKanji {
  final KanjiRepository repository;

  UpdateKanji(this.repository);

  Future<Either<Failure, Kanji>> call(UpdateKanjiParams params) async {
    return await repository.updateKanji(params);
  }
}

class UpdateKanjiParams {
  final int id;
  final String? character;
  final String? onyomi;
  final String? kunyomi;
  final String? meanings;
  final int? strokeCount;
  final int? jlpt;
  final int? grade;
  final int? frequency;
  final String? radicals;

  UpdateKanjiParams({
    required this.id,
    this.character,
    this.onyomi,
    this.kunyomi,
    this.meanings,
    this.strokeCount,
    this.jlpt,
    this.grade,
    this.frequency,
    this.radicals,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (character != null) json['character'] = character;
    if (onyomi != null) json['onyomi'] = onyomi;
    if (kunyomi != null) json['kunyomi'] = kunyomi;
    if (meanings != null) json['meanings'] = meanings;
    if (strokeCount != null) json['stroke_count'] = strokeCount;
    if (jlpt != null) json['jlpt'] = jlpt;
    if (grade != null) json['grade'] = grade;
    if (frequency != null) json['frequency'] = frequency;
    if (radicals != null) json['radicals'] = radicals;
    return json;
  }
}
