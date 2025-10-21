import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<CategoryEntity> call({
    required int id,
    String? name,
    String? description,
  }) {
    return repository.updateCategory(
      id: id,
      name: name,
      description: description,
    );
  }
}
