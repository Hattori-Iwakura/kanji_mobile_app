import 'package:kanji_flutter/domain/entities/kanji_entity.dart';
import '../../domain/repositories/kanji_repository.dart';
import '../remote/kanji_remote_data_source.dart';

class KanjiRepositoryImpl implements KanjiRepository {
  final KanjiRemoteDataSource remote;
  KanjiRepositoryImpl({required this.remote});

  @override
  Future<List<Kanji>> getAll() => remote.fetchAllKanjis();

  @override
  Future<Kanji> create(Map<String, dynamic> data) => remote.createKanji(data);

  @override
  Future<Kanji> update(int id, Map<String, dynamic> data) =>
      remote.updateKanji(id, data);

  @override
  Future<void> delete(int id) => remote.deleteKanji(id);
}
