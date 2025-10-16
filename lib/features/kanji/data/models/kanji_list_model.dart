import '../../domain/entities/kanji_list.dart';
import 'kanji_model.dart';

class KanjiListModel extends KanjiList {
  const KanjiListModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.isPublic,
    required super.createAt,
    required super.updateAt,
    required super.itemCount,
    super.items,
  });

  factory KanjiListModel.fromJson(Map<String, dynamic> json) {
    return KanjiListModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool,
      createAt: DateTime.parse(json['create_at'] as String),
      updateAt: DateTime.parse(json['update_at'] as String),
      itemCount:
          json['_count']?['Items'] as int? ??
          json['itemCount'] as int? ??
          (json['Items'] as List?)?.length ??
          0,
      items: json['Items'] != null
          ? (json['Items'] as List)
                .map((item) => KanjiListItemModel.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'is_public': isPublic,
      'create_at': createAt.toIso8601String(),
      'update_at': updateAt.toIso8601String(),
      'itemCount': itemCount,
      if (items != null)
        'Items': items!
            .map((item) => (item as KanjiListItemModel).toJson())
            .toList(),
    };
  }
}

class KanjiListItemModel extends KanjiListItem {
  const KanjiListItemModel({
    required super.listId,
    required super.kanjiId,
    required super.orderIndex,
    super.notes,
    required super.addedAt,
    super.kanji,
  });

  factory KanjiListItemModel.fromJson(Map<String, dynamic> json) {
    return KanjiListItemModel(
      listId: json['list_id'] as int,
      kanjiId: json['kanji_id'] as int,
      orderIndex: json['order_index'] as int,
      notes: json['notes'] as String?,
      addedAt: DateTime.parse(json['added_at'] as String),
      kanji: json['Kanji'] != null ? KanjiModel.fromJson(json['Kanji']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list_id': listId,
      'kanji_id': kanjiId,
      'order_index': orderIndex,
      'notes': notes,
      'added_at': addedAt.toIso8601String(),
      if (kanji != null) 'Kanji': (kanji as KanjiModel).toJson(),
    };
  }
}
