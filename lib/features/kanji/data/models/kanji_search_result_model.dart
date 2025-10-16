import '../../domain/entities/kanji_search_result.dart';
import 'kanji_model.dart';

class KanjiSearchResultModel extends KanjiSearchResult {
  const KanjiSearchResultModel({required super.data, required super.meta});

  factory KanjiSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List)
        .map((e) => KanjiModel.fromJson(e))
        .toList();

    final meta = PaginationMetaModel.fromJson(json['meta']);

    return KanjiSearchResultModel(data: data, meta: meta);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => (e as KanjiModel).toJson()).toList(),
      'meta': (meta as PaginationMetaModel).toJson(),
    };
  }
}

class PaginationMetaModel extends PaginationMeta {
  const PaginationMetaModel({
    required super.page,
    required super.limit,
    required super.total,
    required super.totalPages,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) {
    return PaginationMetaModel(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}
