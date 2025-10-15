import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/update_kanji.dart';
import '../datasources/kanji_remote_datasource.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiRemoteDataSource remoteDataSource;

  KanjiRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Kanji>>> getAllKanji() async {
    try {
      final kanjiList = await remoteDataSource.getAllKanji();
      return Right(kanjiList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> getKanjiById(int id) async {
    try {
      final kanji = await remoteDataSource.getKanjiById(id);
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> getKanjiByCharacter(String character) async {
    try {
      final kanji = await remoteDataSource.getKanjiByCharacter(character);
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByJlpt(int level) async {
    try {
      final allKanji = await remoteDataSource.getAllKanji();
      final filtered = allKanji.where((k) => k.jlpt == level).toList();
      return Right(filtered);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiByGrade(int grade) async {
    try {
      final allKanji = await remoteDataSource.getAllKanji();
      final filtered = allKanji.where((k) => k.grade == grade).toList();
      return Right(filtered);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> createKanji(CreateKanjiParams params) async {
    try {
      final kanji = await remoteDataSource.createKanji(params);
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> updateKanji(UpdateKanjiParams params) async {
    try {
      final kanji = await remoteDataSource.updateKanji(params);
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> deleteKanji(int id) async {
    try {
      final kanji = await remoteDataSource.deleteKanji(id);
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
