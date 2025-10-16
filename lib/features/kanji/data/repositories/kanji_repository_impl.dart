import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kanji.dart';
import '../../domain/entities/kanji_detail.dart';
import '../../domain/entities/kanji_example.dart';
import '../../domain/entities/kanji_list.dart';
import '../../domain/entities/kanji_progress.dart';
import '../../domain/entities/kanji_search_result.dart';
import '../../domain/entities/progress_summary.dart';
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

  // ==================== Search & Filter ====================
  @override
  Future<Either<Failure, KanjiSearchResult>> searchKanji({
    String? query,
    List<int>? jlptLevels,
    List<int>? grades,
    int? minStrokes,
    int? maxStrokes,
    String? radical,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final result = await remoteDataSource.searchKanji(
        query: query,
        jlptLevels: jlptLevels,
        grades: grades,
        minStrokes: minStrokes,
        maxStrokes: maxStrokes,
        radical: radical,
        page: page,
        limit: limit,
        sortBy: sortBy,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Kanji Detail & Examples ====================
  @override
  Future<Either<Failure, KanjiDetail>> getKanjiDetail(String character) async {
    try {
      final detail = await remoteDataSource.getKanjiDetail(character);
      return Right(detail);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<KanjiExample>>> getKanjiExamples(
    String character, {
    int? limit,
  }) async {
    try {
      final examples = await remoteDataSource.getKanjiExamples(
        character,
        limit: limit,
      );
      return Right(examples);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Kanji Lists ====================
  @override
  Future<Either<Failure, KanjiList>> createList({
    required String name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final list = await remoteDataSource.createList(
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<KanjiList>>> getUserLists() async {
    try {
      final lists = await remoteDataSource.getUserLists();
      return Right(lists);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, KanjiList>> getListDetail(int listId) async {
    try {
      final list = await remoteDataSource.getListDetail(listId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addKanjiToList({
    required int listId,
    required List<String> kanjiCharacters,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.addKanjiToList(
        listId: listId,
        kanjiCharacters: kanjiCharacters,
        notes: notes,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeKanjiFromList({
    required int listId,
    required int kanjiId,
  }) async {
    try {
      await remoteDataSource.removeKanjiFromList(
        listId: listId,
        kanjiId: kanjiId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteList(int listId) async {
    try {
      await remoteDataSource.deleteList(listId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reorderList({
    required int listId,
    required List<int> kanjiIds,
  }) async {
    try {
      await remoteDataSource.reorderList(listId: listId, kanjiIds: kanjiIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // ==================== Progress Tracking ====================
  @override
  Future<Either<Failure, ProgressSummary>> getProgressSummary() async {
    try {
      final summary = await remoteDataSource.getProgressSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, KanjiProgress?>> getKanjiProgress(
    String character,
  ) async {
    try {
      final progress = await remoteDataSource.getKanjiProgress(character);
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, KanjiProgress>> updateProgress({
    required String character,
    required ProgressStatus status,
  }) async {
    try {
      final progress = await remoteDataSource.updateProgress(
        character: character,
        status: status,
      );
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, KanjiProgress>> recordReview({
    required String character,
    required bool correct,
  }) async {
    try {
      final progress = await remoteDataSource.recordReview(
        character: character,
        correct: correct,
      );
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
