import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji.dart';
import '../usecases/create_kanji.dart';
import '../usecases/update_kanji.dart';

abstract class KanjiRepository {
  Future<Either<Failure, List<Kanji>>> getAllKanji();
  Future<Either<Failure, Kanji>> getKanjiById(int id);
  Future<Either<Failure, Kanji>> getKanjiByCharacter(String character);
  Future<Either<Failure, List<Kanji>>> getKanjiByJlpt(int level);
  Future<Either<Failure, List<Kanji>>> getKanjiByGrade(int grade);
  
  // CRUD methods for Admin
  Future<Either<Failure, Kanji>> createKanji(CreateKanjiParams params);
  Future<Either<Failure, Kanji>> updateKanji(UpdateKanjiParams params);
  Future<Either<Failure, Kanji>> deleteKanji(int id);
}
