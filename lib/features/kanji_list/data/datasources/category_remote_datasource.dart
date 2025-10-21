import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoint.dart';
import '../models/category.dart';

abstract class CategoryRemoteDataSource {
  Future<List<Category>> getAllCategories();
  Future<Category> getCategoryById(int id);
  Future<Category> createCategory({required String name, String? description});
  Future<Category> updateCategory({
    required int id,
    String? name,
    String? description,
  });
  Future<void> deleteCategory(int id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load categories',
      );
    }
  }

  @override
  Future<Category> getCategoryById(int id) async {
    try {
      final response = await _apiClient.get('/categories/$id');
      return Category.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load category');
    }
  }

  @override
  Future<Category> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
      };

      final response = await _apiClient.post('/categories', data: data);
      return Category.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to create category',
      );
    }
  }

  @override
  Future<Category> updateCategory({
    required int id,
    String? name,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final response = await _apiClient.put('/categories/$id', data: data);
      return Category.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update category',
      );
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _apiClient.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete category',
      );
    }
  }
}
