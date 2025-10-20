import '../../domain/entities/kanji_list_entity.dart';

/// Kanji List model extending KanjiListEntity
class KanjiList extends KanjiListEntity {
  final String type; // 'SYSTEM' or 'CUSTOM' - derived from userId
  final String? level; // 'N5', 'N4', 'N3', 'N2', 'N1' for SYSTEM lists

  const KanjiList({
    required super.id,
    required super.name,
    super.description,
    required super.userId,
    required super.isPublic,
    required super.totalKanji,
    required super.createAt,
    required super.updateAt,
    required this.type,
    this.level,
  });

  factory KanjiList.fromJson(Map<String, dynamic> json) {
    // Backend returns: { id, userId (nullable), name, description, isPublic, items: [...], createdAt, updatedAt }
    // Determine type: SYSTEM lists have userId = null
    final int userId =
        json['userId'] as int? ?? 0; // Default to 0 for system lists
    final String type = json['userId'] == null ? 'SYSTEM' : 'CUSTOM';

    // Extract JLPT level from name for SYSTEM lists (e.g., "JLPT N5 Kanji" → "N5")
    String? level;
    if (type == 'SYSTEM' && json['name'] != null) {
      final name = json['name'] as String;
      final match = RegExp(r'N[1-5]').firstMatch(name);
      if (match != null) {
        level = match.group(0);
      }
    }

    // Count kanji from items array or use totalKanji if available
    int totalKanji = 0;
    if (json['totalKanji'] != null) {
      totalKanji = json['totalKanji'] as int;
    } else if (json['items'] != null && json['items'] is List) {
      totalKanji = (json['items'] as List).length;
    }

    return KanjiList(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: userId,
      isPublic: json['isPublic'] as bool? ?? false,
      totalKanji: totalKanji,
      createAt: DateTime.parse(json['createdAt'] as String),
      updateAt: DateTime.parse(json['updatedAt'] as String),
      type: type,
      level: level,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId == 0 ? null : userId,
      'isPublic': isPublic,
      'totalKanji': totalKanji,
      'createdAt': createAt.toIso8601String(),
      'updatedAt': updateAt.toIso8601String(),
      'type': type,
      'level': level,
    };
  }

  KanjiListEntity toEntity() {
    return KanjiListEntity(
      id: id,
      name: name,
      description: description,
      userId: userId,
      isPublic: isPublic,
      totalKanji: totalKanji,
      createAt: createAt,
      updateAt: updateAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, type, level];
}
