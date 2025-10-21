import '../../domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<CategoryEntity> getCategoryById(int id);
  Future<CategoryEntity> createCategory({
    required String name,
    String? description,
  });
  Future<CategoryEntity> updateCategory({
    required int id,
    String? name,
    String? description,
  });
  Future<void> deleteCategory(int id);
}
