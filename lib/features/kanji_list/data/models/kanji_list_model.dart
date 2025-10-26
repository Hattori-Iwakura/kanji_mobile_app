import '../../domain/entities/kanji_list.dart';
import '../../../kanji/data/models/kanji_model.dart';

/// Model for KanjiListItem (single kanji in a list)
class KanjiListItemModel {
  final int id;
  final int listId;
  final int kanjiId;
  final int order;
  final KanjiModel kanji;

  KanjiListItemModel({
    required this.id,
    required this.listId,
    required this.kanjiId,
    required this.order,
    required this.kanji,
  });

  factory KanjiListItemModel.fromJson(Map<String, dynamic> json) {
    return KanjiListItemModel(
      id: json['id'] as int,
      listId: json['listId'] as int,
      kanjiId: json['kanjiId'] as int,
      order: json['order'] as int,
      kanji: KanjiModel.fromJson(json['kanji'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'kanjiId': kanjiId,
      'order': order,
      'kanji': kanji.toJson(),
    };
  }
}

/// Model for KanjiList
class KanjiListModel {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<KanjiListItemModel> items;
  final String userName;
  final String? userEmail;

  KanjiListModel({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.userName,
    this.userEmail,
  });

  factory KanjiListModel.fromJson(Map<String, dynamic> json) {
    return KanjiListModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as int,
      isPublic: json['isPublic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    KanjiListItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      userName: json['user']?['account'] as String? ?? 'Unknown',
      userEmail: json['user']?['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'user': {'account': userName, 'email': userEmail},
    };
  }

  /// Convert model to entity
  KanjiList toEntity() {
    return KanjiList(
      id: id,
      name: name,
      description: description,
      userId: userId,
      isPublic: isPublic,
      createdAt: createdAt,
      updatedAt: updatedAt,
      items: items.map((item) => item.toEntity()).toList(),
      userName: userName,
      userEmail: userEmail,
    );
  }
}

/// Extension to convert KanjiListItemModel to entity
extension KanjiListItemModelX on KanjiListItemModel {
  KanjiListItem toEntity() {
    return KanjiListItem(
      id: id,
      listId: listId,
      kanjiId: kanjiId,
      order: order,
      kanji: kanji.toEntity(),
    );
  }
}

/// Response model for paginated kanji lists
class KanjiListsResponse {
  final List<KanjiListModel> data;
  final int total;
  final int limit;
  final int offset;

  KanjiListsResponse({
    required this.data,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory KanjiListsResponse.fromJson(Map<String, dynamic> json) {
    return KanjiListsResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => KanjiListModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }
}
