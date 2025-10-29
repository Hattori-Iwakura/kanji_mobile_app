import '../../domain/entities/kanji_table.dart';
import '../../../kanji/data/models/kanji_model.dart';

class KanjiTableModel extends KanjiTable {
  const KanjiTableModel({
    required super.id,
    required super.name,
    super.description,
    required super.isPublic,
    super.userId,
    super.categoryId,
    required super.createdAt,
    required super.updatedAt,
    super.items,
    super.user,
  });

  factory KanjiTableModel.fromJson(Map<String, dynamic> json) {
    return KanjiTableModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['isPublic'] as bool,
      userId: json['userId'] as int?,
      categoryId: json['categoryId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
                .map(
                  (e) =>
                      KanjiTableItemModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      user: json['user'] != null
          ? KanjiTableUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'userId': userId,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (items != null)
        'items': items!
            .map((e) => (e as KanjiTableItemModel).toJson())
            .toList(),
      if (user != null) 'user': (user! as KanjiTableUserModel).toJson(),
    };
  }
}

class KanjiTableItemModel extends KanjiTableItem {
  const KanjiTableItemModel({
    required super.id,
    required super.listId,
    required super.kanjiId,
    required super.order,
    super.kanji,
  });

  factory KanjiTableItemModel.fromJson(Map<String, dynamic> json) {
    return KanjiTableItemModel(
      id: json['id'] as int,
      listId: json['listId'] as int,
      kanjiId: json['kanjiId'] as int,
      order: json['order'] as int,
      kanji: json['kanji'] != null
          ? KanjiModel.fromJson(json['kanji'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'kanjiId': kanjiId,
      'order': order,
      if (kanji != null) 'kanji': (kanji! as KanjiModel).toJson(),
    };
  }
}

class KanjiTableUserModel extends KanjiTableUser {
  const KanjiTableUserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory KanjiTableUserModel.fromJson(Map<String, dynamic> json) {
    return KanjiTableUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class PublishRequestModel extends PublishRequest {
  const PublishRequestModel({
    required super.id,
    required super.listId,
    required super.userId,
    required super.status,
    required super.createdAt,
    super.reviewedAt,
    super.reviewedBy,
    super.message,
  });

  factory PublishRequestModel.fromJson(Map<String, dynamic> json) {
    return PublishRequestModel(
      id: json['id'] as int,
      listId: json['listId'] as int,
      userId: json['userId'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewedBy: json['reviewedBy'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'userId': userId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (message != null) 'message': message,
    };
  }
}
