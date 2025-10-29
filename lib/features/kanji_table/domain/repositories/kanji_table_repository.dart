import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kanji_table.dart';

abstract class KanjiTableRepository {
  // Get tables by JLPT level (N5, N4, N3, N2, N1)
  Future<Either<Failure, List<KanjiTable>>> getTablesByJlpt(String jlptLevel);

  // Get all tables (public + user's own)
  Future<Either<Failure, List<KanjiTable>>> getAllTables({
    String? search,
    String? type, // 'system' or 'custom'
    int? limit,
    int? offset,
  });

  // Get single table by ID
  Future<Either<Failure, KanjiTable>> getTableById(int id);

  // Create new table
  Future<Either<Failure, KanjiTable>> createTable({
    required String name,
    String? description,
    int? categoryId,
    List<int>? kanjiIds,
  });

  // Update table
  Future<Either<Failure, KanjiTable>> updateTable({
    required int id,
    String? name,
    String? description,
    bool? isPublic,
    int? categoryId,
  });

  // Delete table
  Future<Either<Failure, void>> deleteTable(int id);

  // Add kanji to table
  Future<Either<Failure, void>> addKanjiToTable({
    required int tableId,
    required int kanjiId,
  });

  // Remove kanji from table
  Future<Either<Failure, KanjiTable>> removeKanjiFromTable({
    required int tableId,
    required int kanjiId,
  });

  // Request to publish table (make public)
  Future<Either<Failure, PublishRequest>> requestPublish(int tableId);

  // Admin: Get publish requests
  Future<Either<Failure, List<PublishRequest>>> getPublishRequests({
    String? status,
  });

  // Admin: Approve publish request
  Future<Either<Failure, PublishRequest>> approvePublishRequest(int requestId);

  // Admin: Reject publish request
  Future<Either<Failure, PublishRequest>> rejectPublishRequest({
    required int requestId,
    String? reason,
  });
}
