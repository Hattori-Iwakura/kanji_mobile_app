import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final categories = await remoteDataSource.getAllCategories();
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<CategoryEntity> getCategoryById(int id) async {
    try {
      final category = await remoteDataSource.getCategoryById(id);
      return category.toEntity();
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  @override
  Future<CategoryEntity> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      final category = await remoteDataSource.createCategory(
        name: name,
        description: description,
      );
      return category.toEntity();
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<CategoryEntity> updateCategory({
    required int id,
    String? name,
    String? description,
  }) async {
    try {
      final category = await remoteDataSource.updateCategory(
        id: id,
        name: name,
        description: description,
      );
      return category.toEntity();
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await remoteDataSource.deleteCategory(id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
