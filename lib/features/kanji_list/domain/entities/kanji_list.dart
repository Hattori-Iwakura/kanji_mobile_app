import 'package:equatable/equatable.dart';
import '../../../kanji/domain/entities/kanji.dart';

/// KanjiListItem entity - represents a single kanji in a list
class KanjiListItem extends Equatable {
  final int id;
  final int listId;
  final int kanjiId;
  final int order;
  final Kanji kanji;

  const KanjiListItem({
    required this.id,
    required this.listId,
    required this.kanjiId,
    required this.order,
    required this.kanji,
  });

  @override
  List<Object?> get props => [id, listId, kanjiId, order, kanji];
}

/// KanjiList entity - represents a custom kanji list
class KanjiList extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<KanjiListItem> items;
  final String userName;
  final String? userEmail;

  const KanjiList({
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

  /// Get total number of kanji in list
  int get totalKanji => items.length;

  /// Check if list belongs to user
  bool isOwnedBy(int userId) => this.userId == userId;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    userId,
    isPublic,
    createdAt,
    updatedAt,
    items,
    userName,
    userEmail,
  ];
}
