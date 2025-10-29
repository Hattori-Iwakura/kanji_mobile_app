import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/kanji_vg_service.dart';
import '../../../../core/services/kanji_alive_service.dart';
import '../../../../core/services/jisho_service.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/entities/kanji_detail.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../../domain/usecases/create_kanji.dart';
import '../../domain/usecases/update_kanji.dart';
import '../datasources/kanji_remote_data_source.dart';
import '../models/kanji_detail_model.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiRemoteDataSource remoteDataSource;
  final KanjiVGService kanjiVGService;
  final KanjiAliveService kanjiAliveService;
  final JishoService jishoService;

  KanjiRepositoryImpl({
    required this.remoteDataSource,
    required this.kanjiVGService,
    required this.kanjiAliveService,
    required this.jishoService,
  });

  @override
  Future<Either<Failure, List<Kanji>>> getKanjiList({
    int? jlpt,
    int? grade,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      final kanji = await remoteDataSource.getKanjiList(
        jlpt: jlpt,
        grade: grade,
        search: search,
        limit: limit,
        offset: offset,
      );
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      final result = await remoteDataSource.searchKanji(
        query: query,
        jlptLevels: jlptLevels,
        grades: grades,
        minStrokes: minStrokes,
        maxStrokes: maxStrokes,
        page: page,
        limit: limit,
        sortBy: sortBy,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
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
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
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
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, KanjiDetail>> getKanjiDetail(String character) async {
    try {
      // Get base kanji info from backend
      final kanji = await remoteDataSource.getKanjiByCharacter(character);

      // Fetch data from external APIs in parallel
      final results = await Future.wait([
        kanjiVGService.getStrokeOrderSVG(character),
        kanjiAliveService.getKanjiInfo(character),
        jishoService.searchWord(character),
      ]);

      final strokePaths = results[0] as List<String>?;
      final kanjiAliveData = results[1] as Map<String, dynamic>?;
      final jishoData = results[2] as Map<String, dynamic>?;

      // Combine all data
      final detail = KanjiDetailModel.fromMultipleSources(
        character: kanji.character,
        meanings: kanji.meanings,
        onyomi: kanji.onyomi,
        kunyomi: kanji.kunyomi,
        strokeCount: kanji.strokeCount,
        kanjiAliveData: kanjiAliveData,
        jishoData: jishoData,
        strokePaths: strokePaths,
      );

      return Right(detail);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Kanji>>> searchByCanvas(
    String imageBase64,
  ) async {
    try {
      final kanji = await remoteDataSource.searchByCanvas(imageBase64);
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> createKanji(CreateKanjiParams params) async {
    try {
      final kanji = await remoteDataSource.createKanji(params.toJson());
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Kanji>> updateKanji(UpdateKanjiParams params) async {
    try {
      final kanji = await remoteDataSource.updateKanji(
        params.id,
        params.toJson(),
      );
      return Right(kanji);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteKanji(int id) async {
    try {
      await remoteDataSource.deleteKanji(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
