import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/kanji_repository.dart';

class GetKanjiStats implements UseCase<KanjiStatsResult, NoParams> {
  final KanjiRepository repository;

  GetKanjiStats(this.repository);

  @override
  Future<Either<Failure, KanjiStatsResult>> call(NoParams params) async {
    final result = await repository.getAllKanji();

    return result.fold((failure) => Left(failure), (kanjiList) {
      final stats = KanjiStatsResult(
        totalKanji: kanjiList.length,
        byGrade: _countByGrade(kanjiList),
        byJlpt: _countByJlpt(kanjiList),
      );
      return Right(stats);
    });
  }

  Map<int, int> _countByGrade(List kanjiList) {
    final Map<int, int> gradeCount = {};
    for (var kanji in kanjiList) {
      if (kanji.grade != null) {
        gradeCount[kanji.grade!] = (gradeCount[kanji.grade!] ?? 0) + 1;
      }
    }
    return gradeCount;
  }

  Map<int, int> _countByJlpt(List kanjiList) {
    final Map<int, int> jlptCount = {};
    for (var kanji in kanjiList) {
      if (kanji.jlptNew != null) {
        jlptCount[kanji.jlptNew!] = (jlptCount[kanji.jlptNew!] ?? 0) + 1;
      }
    }
    return jlptCount;
  }
}

class KanjiStatsResult {
  final int totalKanji;
  final Map<int, int> byGrade;
  final Map<int, int> byJlpt;

  KanjiStatsResult({
    required this.totalKanji,
    required this.byGrade,
    required this.byJlpt,
  });
}
