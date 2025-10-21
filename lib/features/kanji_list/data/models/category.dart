import '../../domain/entities/category_entity.dart';

/// Category model extending CategoryEntity
class Category extends CategoryEntity {
  const Category({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => super.props;
}
