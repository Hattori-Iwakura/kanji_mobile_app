import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../repositories/kanji_repository.dart';

class CreateKanji {
  final KanjiRepository repository;

  CreateKanji(this.repository);

  Future<Either<Failure, Kanji>> call(CreateKanjiParams params) async {
    return await repository.createKanji(params);
  }
}

class CreateKanjiParams {
  final String character;
  final String meanings;
  final String onReadings;
  final String kunReadings;
  final int? jlptLevel;
  final int? grade;
  final int strokeCount;
  final int frequency;
  final List<String>? tags;

  CreateKanjiParams({
    required this.character,
    required this.meanings,
    required this.onReadings,
    required this.kunReadings,
    this.jlptLevel,
    this.grade,
    required this.strokeCount,
    required this.frequency,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'meanings': meanings,
      'onReadings': onReadings,
      'kunReadings': kunReadings,
      if (jlptLevel != null) 'jlptLevel': jlptLevel,
      if (grade != null) 'grade': grade,
      'strokeCount': strokeCount,
      'frequency': frequency,
      if (tags != null) 'tags': tags,
    };
  }
}
