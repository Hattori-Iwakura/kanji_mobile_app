import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kanji_flutter/domain/entities/kanji_entity.dart';

class KanjiRemoteDataSource {
  final String baseUrl;
  KanjiRemoteDataSource({required this.baseUrl});

  Future<List<Kanji>> fetchAllKanjis() async {
    final res = await http.get(Uri.parse('$baseUrl/api/kanji'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load kanji: ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    List<dynamic> dataList;

    if (decoded is List) {
      dataList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      // common shape: { data: [...]} or { kanji: [...] }
      final foundList =
          decoded['data'] ??
          decoded['kanji'] ??
          decoded.values.firstWhere(
            (v) => v is List,
            orElse: () => <dynamic>[],
          );
      dataList = foundList is List ? foundList : <dynamic>[];
    } else {
      dataList = <dynamic>[];
    }

    return dataList
        .map((e) => Kanji.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Kanji> createKanji(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/kanji/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create kanji: ${res.statusCode}');
    }
    return Kanji.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Kanji> updateKanji(int id, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/kanji/update/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update kanji: ${res.statusCode}');
    }
    return Kanji.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteKanji(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/kanji/$id'));
    if (res.statusCode != 200) {
      throw Exception('Failed to delete kanji: ${res.statusCode}');
    }
  }
}
