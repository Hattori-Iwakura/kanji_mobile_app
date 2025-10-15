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
  final String? onyomi;
  final String? kunyomi;
  final String meanings;
  final int? strokeCount;
  final int? jlpt;
  final int? grade;
  final int? frequency;
  final String? radicals;

  CreateKanjiParams({
    required this.character,
    this.onyomi,
    this.kunyomi,
    required this.meanings,
    this.strokeCount,
    this.jlpt,
    this.grade,
    this.frequency,
    this.radicals,
  });

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      if (onyomi != null) 'onyomi': onyomi,
      if (kunyomi != null) 'kunyomi': kunyomi,
      'meanings': meanings,
      if (strokeCount != null) 'stroke_count': strokeCount,
      if (jlpt != null) 'jlpt': jlpt,
      if (grade != null) 'grade': grade,
      if (frequency != null) 'frequency': frequency,
      if (radicals != null) 'radicals': radicals,
    };
  }
}
