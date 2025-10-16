import 'package:equatable/equatable.dart';
import 'kanji.dart';

class KanjiList extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createAt;
  final DateTime updateAt;
  final int itemCount;
  final List<KanjiListItem>? items; // Optional, loaded when needed

  const KanjiList({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isPublic,
    required this.createAt,
    required this.updateAt,
    required this.itemCount,
    this.items,
  });

  // Get preview kanji (first 5)
  List<KanjiListItem> get previewItems {
    if (items == null) return [];
    return items!.take(5).toList();
  }

  // Copy with method for immutability
  KanjiList copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    bool? isPublic,
    DateTime? createAt,
    DateTime? updateAt,
    int? itemCount,
    List<KanjiListItem>? items,
  }) {
    return KanjiList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      itemCount: itemCount ?? this.itemCount,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    isPublic,
    createAt,
    updateAt,
    itemCount,
    items,
  ];
}

class KanjiListItem extends Equatable {
  final int listId;
  final int kanjiId;
  final int orderIndex;
  final String? notes;
  final DateTime addedAt;
  final Kanji? kanji; // Optional, loaded when needed

  const KanjiListItem({
    required this.listId,
    required this.kanjiId,
    required this.orderIndex,
    this.notes,
    required this.addedAt,
    this.kanji,
  });

  // Copy with method for immutability
  KanjiListItem copyWith({
    int? listId,
    int? kanjiId,
    int? orderIndex,
    String? notes,
    DateTime? addedAt,
    Kanji? kanji,
  }) {
    return KanjiListItem(
      listId: listId ?? this.listId,
      kanjiId: kanjiId ?? this.kanjiId,
      orderIndex: orderIndex ?? this.orderIndex,
      notes: notes ?? this.notes,
      addedAt: addedAt ?? this.addedAt,
      kanji: kanji ?? this.kanji,
    );
  }

  @override
  List<Object?> get props => [
    listId,
    kanjiId,
    orderIndex,
    notes,
    addedAt,
    kanji,
  ];
}
