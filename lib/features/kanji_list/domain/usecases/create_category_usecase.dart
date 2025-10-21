import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<CategoryEntity> call({required String name, String? description}) {
    return repository.createCategory(name: name, description: description);
  }
}
