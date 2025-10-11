import 'package:kanji_flutter/domain/entities/kanji_entity.dart';

abstract class KanjiRepository {
  Future<List<Kanji>> getAll();
  Future<Kanji> create(Map<String, dynamic> data);
  Future<Kanji> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}
