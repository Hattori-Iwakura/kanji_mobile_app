import 'package:equatable/equatable.dart';
import '../../../kanji/domain/entities/kanji.dart';

class KanjiTable extends Equatable {
  final int id;
  final String name;
  final String? description;
  final bool isPublic;
  final int? userId;
  final int? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<KanjiTableItem>? items;
  final KanjiTableUser? user;

  const KanjiTable({
    required this.id,
    required this.name,
    this.description,
    required this.isPublic,
    this.userId,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.user,
  });

  bool get isSystemTable => userId == null;
  bool get isUserTable => userId != null;
  int get kanjiCount => items?.length ?? 0;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    isPublic,
    userId,
    categoryId,
    createdAt,
    updatedAt,
    items,
    user,
  ];
}

class KanjiTableItem extends Equatable {
  final int id;
  final int listId;
  final int kanjiId;
  final int order;
  final Kanji? kanji;

  const KanjiTableItem({
    required this.id,
    required this.listId,
    required this.kanjiId,
    required this.order,
    this.kanji,
  });

  @override
  List<Object?> get props => [id, listId, kanjiId, order, kanji];
}

class KanjiTableUser extends Equatable {
  final int id;
  final String name;
  final String email;

  const KanjiTableUser({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}

class PublishRequest extends Equatable {
  final int id;
  final int listId;
  final int userId;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final int? reviewedBy;
  final String? message;

  const PublishRequest({
    required this.id,
    required this.listId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.message,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [
    id,
    listId,
    userId,
    status,
    createdAt,
    reviewedAt,
    reviewedBy,
    message,
  ];
}
