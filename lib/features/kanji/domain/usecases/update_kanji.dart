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
  final String? meanings;
  final String? onReadings;
  final String? kunReadings;
  final int? jlptLevel;
  final int? grade;
  final int? strokeCount;
  final int? frequency;
  final List<String>? tags;

  UpdateKanjiParams({
    required this.id,
    this.character,
    this.meanings,
    this.onReadings,
    this.kunReadings,
    this.jlptLevel,
    this.grade,
    this.strokeCount,
    this.frequency,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (character != null) data['character'] = character;
    if (meanings != null) data['meanings'] = meanings;
    if (onReadings != null) data['onReadings'] = onReadings;
    if (kunReadings != null) data['kunReadings'] = kunReadings;
    if (jlptLevel != null) data['jlptLevel'] = jlptLevel;
    if (grade != null) data['grade'] = grade;
    if (strokeCount != null) data['strokeCount'] = strokeCount;
    if (frequency != null) data['frequency'] = frequency;
    if (tags != null) data['tags'] = tags;
    return data;
  }
}
