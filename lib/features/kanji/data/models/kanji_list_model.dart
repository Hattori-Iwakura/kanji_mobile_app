import '../../domain/entities/kanji_list.dart';

class KanjiListModel extends KanjiList {
  const KanjiListModel({
    required super.id,
    required super.name,
    super.description,
    required super.filterType,
    super.filterValue,
    super.frequencyMin,
    super.frequencyMax,
    required super.createdAt,
    required super.updatedAt,
    required super.kanjiCount,
  });

  factory KanjiListModel.fromJson(Map<String, dynamic> json) {
    return KanjiListModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      filterType: _filterTypeFromString(json['filter_type']),
      filterValue: json['filter_value'],
      frequencyMin: json['frequency_min'],
      frequencyMax: json['frequency_max'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kanjiCount: json['kanji_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'filter_type': _filterTypeToString(filterType),
      'filter_value': filterValue,
      'frequency_min': frequencyMin,
      'frequency_max': frequencyMax,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'kanji_count': kanjiCount,
    };
  }

  static ListFilterType _filterTypeFromString(String type) {
    switch (type) {
      case 'jlpt_level':
        return ListFilterType.jlptLevel;
      case 'frequency':
        return ListFilterType.frequency;
      case 'grade':
        return ListFilterType.grade;
      case 'custom':
        return ListFilterType.custom;
      default:
        return ListFilterType.custom;
    }
  }

  static String _filterTypeToString(ListFilterType type) {
    switch (type) {
      case ListFilterType.jlptLevel:
        return 'jlpt_level';
      case ListFilterType.frequency:
        return 'frequency';
      case ListFilterType.grade:
        return 'grade';
      case ListFilterType.custom:
        return 'custom';
    }
  }
}
