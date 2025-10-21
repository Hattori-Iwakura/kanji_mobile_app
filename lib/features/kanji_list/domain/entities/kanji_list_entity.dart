import 'package:equatable/equatable.dart';
import 'category_entity.dart';

class KanjiListEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final bool isPublic;
  final int totalKanji;
  final DateTime createAt;
  final DateTime updateAt;
  final int? categoryId;
  final CategoryEntity? category;

  const KanjiListEntity({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.isPublic,
    required this.totalKanji,
    required this.createAt,
    required this.updateAt,
    this.categoryId,
    this.category,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    userId,
    isPublic,
    totalKanji,
    createAt,
    updateAt,
    categoryId,
    category,
  ];
}
