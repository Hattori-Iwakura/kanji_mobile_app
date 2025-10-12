import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';

abstract class KanjiRepository {
  Future<Either<Failure, List<Kanji>>> getAllKanji();
  Future<Either<Failure, Kanji>> getKanjiById(int id);
  Future<Either<Failure, List<Kanji>>> getKanjiByGrade(int grade);
  Future<Either<Failure, List<Kanji>>> getKanjiByJlptLevel(int level);
  Future<Either<Failure, List<Kanji>>> searchKanji(String query);
}
