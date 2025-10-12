import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../datasources/kanji_local_data_source.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiLocalDataSource localDataSource;

  KanjiRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Kanji>>> getAllKanji() async {
    try {
      final kanji = await localDataSource.getAllKanji();
      return Right(kanji);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, Kanji>> getKanjiById(int id) async {
    try {
      final kanji = await localDataSource.getKanjiById(id);
      return Right(kanji);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByGrade(int grade) async {
    try {
      final kanji = await localDataSource.getKanjiByGrade(grade);
      return Right(kanji);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByJlptLevel(int level) async {
    try {
      final kanji = await localDataSource.getKanjiByJlptLevel(level);
      return Right(kanji);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> searchKanji(String query) async {
    try {
      final kanji = await localDataSource.searchKanji(query);
      return Right(kanji);
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
